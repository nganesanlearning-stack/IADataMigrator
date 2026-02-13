#!/bin/bash
# setup-docker-environment.sh
# Script to set up Docker environment for Airflow with Java support

echo "====================================================="
echo "Setting up Docker Environment for Airflow with Java"
echo "====================================================="

# Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH."
    echo "Please install Docker Desktop for Windows before continuing."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: docker-compose is not installed or not in PATH."
    echo "Docker Compose should be included with Docker Desktop for Windows."
    exit 1
fi

# Make sure we're in the project root directory
cd "$(dirname "$0")"

# Create required directories if they don't exist
echo "Creating directory structure..."
mkdir -p ./dags ./logs ./plugins ./scripts ./java-apps/output ./java-apps/archives ./config

# Set up environment file if it doesn't exist
if [ ! -f ./.env ]; then
    echo "Creating .env file..."
    cat > ./.env << 'EOL'
AIRFLOW_UID=50000
AIRFLOW_GID=50000
_AIRFLOW_WWW_USER_USERNAME=airflow
_AIRFLOW_WWW_USER_PASSWORD=airflow
EOL
fi

# Check if docker-compose.yaml exists
if [ ! -f ./docker-compose.yaml ]; then
    echo "docker-compose.yaml not found. Creating a new one..."
    cat > ./docker-compose.yaml << 'EOL'
version: '3'
x-airflow-common: &airflow-common
  image: apache/airflow:2.7.3
  environment:
    &airflow-common-env
    AIRFLOW__CORE__EXECUTOR: LocalExecutor
    AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://airflow:airflow@postgres/airflow
    AIRFLOW__CORE__FERNET_KEY: ''
    AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: 'true'
    AIRFLOW__CORE__LOAD_EXAMPLES: 'false'
    AIRFLOW__API__AUTH_BACKENDS: 'airflow.api.auth.backend.basic_auth,airflow.api.auth.backend.session'
    _PIP_ADDITIONAL_REQUIREMENTS: ${_PIP_ADDITIONAL_REQUIREMENTS:-}
  volumes:
    - ./dags:/opt/airflow/dags
    - ./logs:/opt/airflow/logs
    - ./plugins:/opt/airflow/plugins
    - ./java-apps:/opt/airflow/java-apps
    - ./scripts:/opt/airflow/scripts
    - ./config:/opt/airflow/config
  user: "${AIRFLOW_UID:-50000}:0"
  depends_on:
    &airflow-common-depends-on
    postgres:
      condition: service_healthy

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: airflow
      POSTGRES_DB: airflow
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "airflow"]
      interval: 5s
      retries: 5
    restart: always

  airflow-webserver:
    <<: *airflow-common
    command: webserver
    ports:
      - "8080:8080"
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:8080/health"]
      interval: 10s
      timeout: 10s
      retries: 5
    restart: always
    depends_on:
      <<: *airflow-common-depends-on
      airflow-init:
        condition: service_completed_successfully

  airflow-scheduler:
    <<: *airflow-common
    command: scheduler
    healthcheck:
      test: ["CMD-SHELL", 'airflow jobs check --job-type SchedulerJob --hostname "$${HOSTNAME}"']
      interval: 10s
      timeout: 10s
      retries: 5
    restart: always
    depends_on:
      <<: *airflow-common-depends-on
      airflow-init:
        condition: service_completed_successfully

  airflow-init:
    <<: *airflow-common
    entrypoint: /bin/bash
    command:
      - -c
      - |
        function ver() {
          printf "%04d%04d%04d%04d" $${1//./ }
        }
        airflow_version=$$(PYTHONPATH=. python -c "import airflow; print(airflow.__version__)")
        airflow_version_comparable=$$(ver $${airflow_version})
        min_airflow_version=2.2.0
        min_airflow_version_comparable=$$(ver $${min_airflow_version})
        if (( airflow_version_comparable < min_airflow_version_comparable )); then
          echo
          echo -e "\033[1;31mERROR!!!: Too old Airflow version $${airflow_version}!\033[0m"
          echo "The minimum Airflow version supported: $${min_airflow_version}. Only use this or higher!"
          echo
          exit 1
        fi
        if [[ -z "${AIRFLOW_UID}" ]]; then
          echo
          echo -e "\033[1;33mWARNING!!!: AIRFLOW_UID not set!\033[0m"
          echo "If you are on Linux, you SHOULD follow the instructions below to set "
          echo "AIRFLOW_UID environment variable, otherwise files will be owned by root."
          echo "For other operating systems you can get rid of the warning with manually created .env file:"
          echo "    See: https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html#setting-the-right-airflow-user"
          echo
        fi
        one_meg=1048576
        mem_available=$$(($$(getconf _PHYS_PAGES) * $$(getconf PAGE_SIZE) / one_meg))
        cpus_available=$$(grep -cE 'cpu[0-9]+' /proc/stat)
        disk_available=$$(df / | tail -1 | awk '{print $$4}')
        disk_available=$$(($${disk_available} / one_meg))
        if (( mem_available < 4000 )) ; then
          echo
          echo -e "\033[1;33mWARNING!!!: Not enough memory available for Docker.\033[0m"
          echo "At least 4GB of memory required. You have $$(numfmt --to iec $$((mem_available * one_meg)))"
          echo
        fi
        if (( cpus_available < 2 )); then
          echo
          echo -e "\033[1;33mWARNING!!!: Not enough CPUS available for Docker.\033[0m"
          echo "At least 2 CPUs recommended. You have $${cpus_available}"
          echo
        fi
        if (( disk_available < 10 )); then
          echo
          echo -e "\033[1;33mWARNING!!!: Not enough Disk space available for Docker.\033[0m"
          echo "At least 10 GBs recommended. You have $$(numfmt --to iec $$((disk_available * one_meg)))"
          echo
        fi
        mkdir -p /sources/logs /sources/dags /sources/plugins
        chown -R "${AIRFLOW_UID}:0" /sources/{logs,dags,plugins}
        exec airflow db init

  airflow-cli:
    <<: *airflow-common
    profiles:
      - debug
    environment:
      <<: *airflow-common-env
      CONNECTION_CHECK_MAX_COUNT: "0"
    command:
      - bash
      - -c
      - airflow

volumes:
  postgres-db-volume:
EOL
fi

# Create custom Dockerfile for Airflow with Java
if [ ! -f ./Dockerfile ]; then
    echo "Creating custom Dockerfile with Java..."
    cat > ./Dockerfile << 'EOL'
FROM apache/airflow:2.7.3

USER root

# Install Java 11 and Maven
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        maven \
        wine \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify Java and Maven installation
RUN java -version && mvn -version

# Create needed directories
RUN mkdir -p /opt/airflow/java-apps/output /opt/airflow/java-apps/archives \
    && chmod -R 777 /opt/airflow/java-apps

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

# Switch back to airflow user
USER airflow
EOL
fi

# Create a setup script for installing needed software inside the container
if [ ! -f ./scripts/setup-java-env.sh ]; then
    echo "Creating Java environment setup script..."
    cat > ./scripts/setup-java-env.sh << 'EOL'
#!/bin/bash
# setup-java-env.sh - Script to set up Java environment inside Airflow container

echo "====================================================="
echo "Setting up Java Environment for Airflow"
echo "====================================================="

# Check Java installation
if command -v java >/dev/null 2>&1; then
    echo "Java is installed:"
    java -version
else
    echo "ERROR: Java is not installed!"
    exit 1
fi

# Check Maven installation
if command -v mvn >/dev/null 2>&1; then
    echo "Maven is installed:"
    mvn -version
else
    echo "ERROR: Maven is not installed!"
    exit 1
fi

# Set up JAVA_HOME if not already set
if [ -z "$JAVA_HOME" ]; then
    # Try to find JAVA_HOME
    JAVA_PATH=$(which java)
    JAVA_HOME=$(readlink -f $JAVA_PATH | sed "s:/bin/java::")
    
    echo "Setting JAVA_HOME to $JAVA_HOME"
    export JAVA_HOME
fi

echo "JAVA_HOME = $JAVA_HOME"

# Ensure scripts directory has right permissions
cd /opt/airflow
chmod -R 755 /opt/airflow/scripts

# Compile all Java files in the java-apps directory
cd /opt/airflow/java-apps
echo "Compiling all Java files in $(pwd)..."
javac *.java

echo "Java environment setup completed successfully!"
echo "====================================================="
EOL
    
    # Make script executable
    chmod +x ./scripts/setup-java-env.sh
fi

# Create a sample Java application if not exists
if [ ! -f ./java-apps/SimpleJavaApp.java ]; then
    echo "Creating sample Java application..."
    cat > ./java-apps/SimpleJavaApp.java << 'EOL'
/**
 * Simple Java application to test the Airflow-Java integration
 */
public class SimpleJavaApp {
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("   Simple Java App - Airflow Testing");
        System.out.println("========================================");
        
        System.out.println("Java version: " + System.getProperty("java.version"));
        System.out.println("Java home: " + System.getProperty("java.home"));
        
        // Print arguments if any
        if (args.length > 0) {
            System.out.println("\nArguments passed to the application:");
            for (int i = 0; i < args.length; i++) {
                System.out.println("  Arg " + i + ": " + args[i]);
            }
        } else {
            System.out.println("\nNo arguments were passed to the application.");
        }
        
        // Print environment info
        System.out.println("\nEnvironment Information:");
        System.out.println("  OS: " + System.getProperty("os.name") + " " + 
                           System.getProperty("os.version") + " " + 
                           System.getProperty("os.arch"));
        System.out.println("  User: " + System.getProperty("user.name"));
        System.out.println("  Working Dir: " + System.getProperty("user.dir"));
        
        System.out.println("\nSimple Java App execution completed!");
        System.out.println("========================================");
    }
}
EOL
fi

# Create sample data file if not exists
if [ ! -f ./java-apps/sample_data.csv ]; then
    echo "Creating sample data file..."
    cat > ./java-apps/sample_data.csv << 'EOL'
# Sample Data File
# Format: ID, Name, Value, Date

001, Product A, 45.99, 2025-08-15
002, Product B, 29.99, 2025-08-16
003, Product C, 99.99, 2025-08-16
004, Product D, 149.99, 2025-08-17
005, Product E, 19.99, 2025-08-18
006, Product F, 59.99, 2025-08-19
007, Product G, 39.99, 2025-08-20
008, Product H, 89.99, 2025-08-21
009, Product I, 199.99, 2025-08-22
010, Product J, 24.99, 2025-08-23
EOL
fi

# Build custom Docker image
echo "Building custom Docker image with Java support..."
docker build -t custom-airflow-java .

# Modify docker-compose to use custom image
sed -i 's|image: apache/airflow:2.7.3|image: custom-airflow-java|g' docker-compose.yaml

# Output instructions
echo "====================================================="
echo "Setup complete!"
echo "====================================================="
echo "To start the Airflow environment, run:"
echo "  docker-compose up -d"
echo ""
echo "Access the Airflow web interface at:"
echo "  http://localhost:8080"
echo ""
echo "Default login credentials:"
echo "  Username: airflow"
echo "  Password: airflow"
echo ""
echo "To verify Java environment inside the container:"
echo "  docker exec -it javaairflow-airflow-webserver-1 /opt/airflow/scripts/setup-java-env.sh"
echo ""
echo "To stop the environment, run:"
echo "  docker-compose down"
echo "====================================================="
