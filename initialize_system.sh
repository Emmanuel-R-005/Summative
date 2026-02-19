#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./initialize_system.sh <environment_name>"
    exit 1
fi

ENV_NAME=$1
PROJECT_DIR="grade_system_${ENV_NAME}"

echo "Environment: $ENV_NAME"
echo "Project directory will be: $PROJECT_DIR"



cleanup() {
    echo ""
    echo "Interrupted! Cleaning up..."

    if [ -d "$PROJECT_DIR" ]; then
        tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR"
        rm -rf "$PROJECT_DIR"
        echo "Project archived and removed."
    else
        echo "No project directory to clean."
    fi

    exit 1
}

trap cleanup SIGINT


if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Project already exists."
    exit 1
fi

mkdir "$PROJECT_DIR"
mkdir "$PROJECT_DIR/Data"
mkdir "$PROJECT_DIR/logs"

echo "Project structure created successfully"

cat << EOF > "$PROJECT_DIR/Data/students.csv"
Email,Name,Score
john@example.com,John Doe,85
mary@example.com,Mary Jane,42
sam@example.com,Sam Blue,73
EOF

cat << EOF > "$PROJECT_DIR/Data/settings.json"
{
    "passing_score": 50,
    "honors_score": 80,
    "mode": "live"
}
EOF

cat << EOF > "$PROJECT_DIR/analyse.py" 


import csv
import json
import os
from datetime import datetime
def run_attendance_check():
# 1. Load Config
with open('Helpers/config.json', 'r') as f:
config = json.load(f)
# 2. Archive old reports.log if it exists
if os.path.exists('reports/reports.log'):
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
os.rename('reports/reports.log',
f'reports/reports_{timestamp}.log.archive')
# 3. Process Data
with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log',
'w') as log:
reader = csv.DictReader(f)
total_sessions = config['total_sessions']
log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
for row in reader:
name = row['Names']
email = row['Email']
attended = int(row['Attendance Count'])
# Simple Math: (Attended / Total) * 100
attendance_pct = (attended / total_sessions) * 100
message = ""
if attendance_pct < config['thresholds']['failure']:
message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}
%. You will fail this class."
elif attendance_pct < config['thresholds']['warning']:
message = f"WARNING: {name}, your attendance is
{attendance_pct:.1f}%. Please be careful."
if message:
if config['run_mode'] == "live":
log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}
\n")
print(f"Logged alert for {name}")
else:
print(f"[DRY RUN] Email to {email}: {message}")
if __name__ == "__main__":
run_attendance_check()

EOF

touch "$PROJECT_DIR/logs/run.log"

read -p "Do you want to change passing score? (y/n):" choice

if [ "$choice" == "y" ]; then
 read -p "Enter new passing score: " new_score


sed -i "s/\"passing_score\": [0-9]*/\"passing_score\": $new_score/" "$PROJECT_DIR/Data/settings.json"
fi

python3 --version > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Python detected ✔"
else
    echo "Python not found ⚠"
fi
