#!/bin/bash
# simulate-bat.sh - Simulates the functionality of list-folders.bat

echo "========================================"
echo "Folder Listing Utility"
echo "========================================"
echo "Executed at: $(date)"
echo "Current directory: $(pwd)"
echo

TARGET_DIR="${1:-/opt/airflow}"

echo "Listing folders in: $TARGET_DIR"
echo "========================================"

find "$TARGET_DIR" -maxdepth 1 -type d | sort

echo
echo "========================================"
echo "Listing complete!"
echo "========================================"
