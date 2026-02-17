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
