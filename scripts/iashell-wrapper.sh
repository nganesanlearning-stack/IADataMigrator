#!/bin/bash

# iashell Wrapper Script for Airflow Container
# This script provides a convenient way to run iashell commands within the Airflow environment

set -e  # Exit on any error

# Configuration
JAVA_HOME="/opt/java/temurin-21"
IASHELL_HOME="/opt/airflow/java-apps/iashell/iashell"
IASHELL_BIN="$IASHELL_HOME/bin"
LOG_DIR="$IASHELL_HOME/logs"
OUTPUT_DIR="$IASHELL_HOME/output"

# Function to print usage
print_usage() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -v, --version       Show iashell version"
    echo "  -e, --env           Show environment information"
    echo "  -t, --test          Run test commands"
    echo "  -i, --interactive   Start interactive iashell session"
    echo "  -f, --file FILE     Execute commands from file"
    echo "  -c, --command CMD   Execute specific command"
    echo ""
    echo "Examples:"
    echo "  $0 --env                           # Show environment"
    echo "  $0 --test                          # Run test commands"
    echo "  $0 --interactive                   # Start interactive session"
    echo "  $0 --file /path/to/commands.txt    # Run commands from file"
    echo "  $0 --command 'help'                # Run specific command"
}

# Function to setup environment
setup_environment() {
    echo "Setting up iashell environment..."
    
    # Export environment variables
    export JAVA_HOME="$JAVA_HOME"
    export PATH="$JAVA_HOME/bin:$PATH"
    export IASHELL_HOME="$IASHELL_HOME"
    
    # Create directories if they don't exist
    mkdir -p "$LOG_DIR"
    mkdir -p "$OUTPUT_DIR"
    
    # Make scripts executable
    chmod +x "$IASHELL_BIN/iashell" 2>/dev/null || true
    chmod +x "$IASHELL_BIN/iashell.bat" 2>/dev/null || true
    
    echo "Environment setup completed."
}

# Function to show environment information
show_environment() {
    echo "=== iashell Environment Information ==="
    echo "JAVA_HOME: $JAVA_HOME"
    echo "IASHELL_HOME: $IASHELL_HOME"
    echo "IASHELL_BIN: $IASHELL_BIN"
    echo "LOG_DIR: $LOG_DIR"
    echo "OUTPUT_DIR: $OUTPUT_DIR"
    echo ""
    
    echo "Java Version:"
    if [ -x "$JAVA_HOME/bin/java" ]; then
        "$JAVA_HOME/bin/java" -version
    else
        echo "Java not found at $JAVA_HOME/bin/java"
    fi
    echo ""
    
    echo "iashell Files:"
    echo "  Bash script: $IASHELL_BIN/iashell $([ -f "$IASHELL_BIN/iashell" ] && echo '✓' || echo '✗')"
    echo "  Batch script: $IASHELL_BIN/iashell.bat $([ -f "$IASHELL_BIN/iashell.bat" ] && echo '✓' || echo '✗')"
    echo "  JAR file: $IASHELL_HOME/lib/infoarchive-shell-25.2-exec.jar $([ -f "$IASHELL_HOME/lib/infoarchive-shell-25.2-exec.jar" ] && echo '✓' || echo '✗')"
    echo ""
    
    echo "Directory Contents:"
    echo "  iashell home:"
    ls -la "$IASHELL_HOME/" 2>/dev/null || echo "    Directory not accessible"
    echo "  iashell bin:"
    ls -la "$IASHELL_BIN/" 2>/dev/null || echo "    Directory not accessible"
}

# Function to run test commands
run_test() {
    echo "Running iashell test commands..."
    
    # Create test command file
    local test_file="/tmp/iashell_test_commands.txt"
    cat > "$test_file" << 'EOF'
help
version
exit
EOF
    
    echo "Test commands to execute:"
    cat "$test_file"
    echo ""
    
    # Change to iashell bin directory
    cd "$IASHELL_BIN"
    
    # Run iashell with test commands
    echo "Executing iashell with test commands..."
    ./iashell < "$test_file" 2>&1 || echo "Test completed with exit code $?"
    
    # Clean up
    rm -f "$test_file"
    echo "Test execution completed."
}

# Function to run iashell interactively
run_interactive() {
    echo "Starting interactive iashell session..."
    echo "Type 'exit' to quit the session."
    echo ""
    
    # Change to iashell bin directory
    cd "$IASHELL_BIN"
    
    # Start interactive session
    ./iashell
}

# Function to run commands from file
run_from_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        exit 1
    fi
    
    echo "Running iashell commands from file: $file"
    echo "Commands to execute:"
    cat "$file"
    echo ""
    
    # Change to iashell bin directory
    cd "$IASHELL_BIN"
    
    # Run iashell with commands from file
    ./iashell < "$file" 2>&1 || echo "File execution completed with exit code $?"
}

# Function to run specific command
run_command() {
    local command="$1"
    
    echo "Running iashell command: $command"
    
    # Create temporary command file
    local temp_file="/tmp/iashell_single_command.txt"
    echo "$command" > "$temp_file"
    echo "exit" >> "$temp_file"
    
    # Change to iashell bin directory
    cd "$IASHELL_BIN"
    
    # Run iashell with command
    ./iashell < "$temp_file" 2>&1 || echo "Command execution completed with exit code $?"
    
    # Clean up
    rm -f "$temp_file"
}

# Main script logic
main() {
    # Setup environment first
    setup_environment
    
    # Parse command line arguments
    case "$1" in
        -h|--help)
            print_usage
            ;;
        -v|--version)
            cd "$IASHELL_BIN"
            ./iashell --version 2>&1 || echo "Version check completed"
            ;;
        -e|--env)
            show_environment
            ;;
        -t|--test)
            run_test
            ;;
        -i|--interactive)
            run_interactive
            ;;
        -f|--file)
            if [ -z "$2" ]; then
                echo "Error: File path required for --file option"
                print_usage
                exit 1
            fi
            run_from_file "$2"
            ;;
        -c|--command)
            if [ -z "$2" ]; then
                echo "Error: Command required for --command option"
                print_usage
                exit 1
            fi
            run_command "$2"
            ;;
        "")
            # No arguments provided, show environment and usage
            show_environment
            echo ""
            print_usage
            ;;
        *)
            echo "Error: Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
