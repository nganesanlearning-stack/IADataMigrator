#!/bin/bash
# test-windows-batch.sh - Script to test running a Windows batch file in the Airflow container

echo "====================================================="
echo "Windows Batch File Testing in Docker"
echo "====================================================="

cd /opt/airflow/java-apps
BATCH_FILE="process-data.bat"
DATA_FILE="sample_data.csv"
OUTPUT_DIR="output"

# Check if Wine is available
if command -v wine >/dev/null 2>&1; then
    echo "Wine is available. Can attempt to run Windows batch file directly."
    echo "To run the .bat file with Wine, execute:"
    echo "  wine cmd /c $BATCH_FILE $DATA_FILE $OUTPUT_DIR"
    
    echo "Attempting to run batch file with Wine..."
    wine cmd /c $BATCH_FILE $DATA_FILE $OUTPUT_DIR
    
    if [ $? -eq 0 ]; then
        echo "Batch file executed successfully with Wine!"
    else
        echo "Batch file execution with Wine failed."
    fi
else
    echo "Wine is not available in this container."
    echo "Cannot directly run Windows batch (.bat) files."
    echo "Simulating batch file execution instead..."
    
    # Create output directory
    mkdir -p $OUTPUT_DIR
    
    # The batch file would run these commands, so we'll run them directly
    echo "Step 1: Validating data file..."
    java -cp . DataValidator $DATA_FILE
    
    echo "Step 2: Processing data..."
    java -cp . DataProcessor $DATA_FILE $OUTPUT_DIR/processed_data.txt
    
    echo "Step 3: Generating report..."
    java -cp . ReportGenerator $OUTPUT_DIR/processed_data.txt $OUTPUT_DIR/report.html
    
    echo "Batch simulation completed."
    
    # Check if output files were created
    if [ -f "$OUTPUT_DIR/processed_data.txt" ] && [ -f "$OUTPUT_DIR/report.html" ]; then
        echo "Batch process completed successfully with expected outputs."
    else
        echo "ERROR: Batch process did not create expected output files."
        exit 1
    fi
fi

# Show the contents of the output directory
echo "====================================================="
echo "Output Directory Contents:"
ls -la $OUTPUT_DIR

echo "====================================================="
echo "Contents of processed_data.txt (first 10 lines):"
head -n 10 $OUTPUT_DIR/processed_data.txt

echo "====================================================="
echo "Testing complete!"
echo "====================================================="
