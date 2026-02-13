#!/bin/bash
# Script to check DAG parsing and fix common issues

echo "========================================"
echo "Airflow DAG Validation Script"
echo "========================================"

# Check Airflow version
echo "Checking Airflow version..."
airflow version
echo ""

# List all DAG files
echo "Listing DAG files..."
ls -la /opt/airflow/dags/
echo ""

# Test parsing all DAGs
echo "Testing DAG parsing..."
airflow dags list
if [ $? -eq 0 ]; then
    echo "✅ All DAGs parsed successfully!"
else
    echo "❌ There are DAG parsing issues."
    
    # Try to provide more information about errors
    echo "Detailed error information:"
    airflow dags list-import-errors
fi

echo ""
echo "========================================"
echo "DAG Validation complete"
echo "========================================"
