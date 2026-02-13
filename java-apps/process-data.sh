#!/bin/bash
# process-data.sh
# Sample batch script for Java data processing tasks
# This script demonstrates running Java commands in a batch mode
# To be triggered from an Airflow DAG

# Exit immediately if a command fails
set -e

# Print execution information
echo "============================================================"
echo "Java Data Processing Batch Script"
echo "============================================================"
echo "Script started at: $(date)"
echo "Current user: $(whoami)"
echo "Working directory: $(pwd)"

# Check for arguments
echo "Checking arguments..."
if [ "$#" -lt 1 ]; then
    echo "ERROR: Missing required arguments!"
    echo "Usage: $0 <input_file> [output_directory]"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_DIR="${2:-./output}"

echo "Input file: $INPUT_FILE"
echo "Output directory: $OUTPUT_DIR"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Display Java version
echo "============================================================"
echo "Java Environment:"
echo "Java Version: $(java -version 2>&1 | head -n 1)"
echo "Java Home: $JAVA_HOME"
echo "============================================================"

# Execute first Java task - Data validation
echo "Step 1: Validating data file..."
java -cp . DataValidator "$INPUT_FILE"

# Execute second Java task - Data processing
echo "Step 2: Processing data..."
java -cp . DataProcessor "$INPUT_FILE" "$OUTPUT_DIR/processed_data.txt"

# Execute third Java task - Generate report
echo "Step 3: Generating report..."
java -cp . ReportGenerator "$OUTPUT_DIR/processed_data.txt" "$OUTPUT_DIR/report.html"

# Print completion message
echo "============================================================"
echo "Batch processing completed successfully!"
echo "Output files:"
ls -la "$OUTPUT_DIR"
echo "Script completed at: $(date)"
echo "============================================================"

# Return success
exit 0
