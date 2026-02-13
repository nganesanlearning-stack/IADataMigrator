# Setup Instructions for Airflow with Java in Docker

## Prerequisites

1. **Docker Desktop for Windows** - Ensure it's installed and running
2. **Windows 10/11** with WSL2 enabled
3. **At least 8GB RAM** available for Docker containers
4. **PowerShell** or Command Prompt access

## Quick Setup Steps

### 1. Navigate to Project Directory

Open PowerShell and navigate to your project directory:
```powershell
cd C:\Docker\javaairflow
```

### 2. Build and Start Services

Build the custom Airflow image with Java and start all services:
```powershell
docker-compose -f docker/docker-compose.yml up --build -d
```

### 3. Wait for Initialization

The services will take a few minutes to start. Monitor the logs:
```powershell
docker-compose -f docker/docker-compose.yml logs -f airflow-init
```

### 4. Access Airflow UI

Once initialization is complete, access the Airflow web interface:
- URL: http://localhost:8080
- Username: `admin`
- Password: `admin123`

### 5. Verify Java Environment

You can run the health check to verify Java is working:
```powershell
docker-compose -f docker/docker-compose.yml exec airflow-webserver bash /opt/airflow/scripts/health-check.sh
```

## Testing Java Integration

### 1. Enable Example DAG

1. Go to the Airflow UI (http://localhost:8080)
2. Find the `java_example_dag` in the DAGs list
3. Toggle it on by clicking the switch
4. Click on the DAG to view its tasks

### 2. Trigger DAG Execution

1. Click "Trigger DAG" button
2. Monitor the execution in the Graph or Tree view
3. Check task logs to see Java execution output

### 3. Manual Java Testing

Execute Java commands directly in the container:
```powershell
# Access the webserver container
docker-compose -f docker/docker-compose.yml exec airflow-webserver bash

# Inside the container, test Java
java -version
cd /opt/airflow/java-apps
javac DataProcessor.java
java DataProcessor input.txt output.txt
```

## Project Structure Overview

```
C:\Docker\javaairflow\
├── docker/
│   ├── Dockerfile.airflow-java     # Custom Airflow image with Java 17
│   └── docker-compose.yml          # Complete Docker setup
├── dags/
│   └── java_example_dag.py         # Example DAG with Java tasks
├── java-apps/
│   ├── jars/                      # Place your JAR files here
│   ├── configs/                   # Java configuration files
│   ├── logs/                      # Java application logs
│   └── DataProcessor.java         # Example Java application
├── scripts/
│   ├── health-check.sh            # Java environment health check
│   └── init-airflow.sh           # Initialization script
├── logs/                          # Airflow logs
├── plugins/                       # Airflow plugins
├── config/                        # Airflow configuration
├── .env                           # Environment variables
└── README.md                      # Main documentation
```

## Adding Your Java Applications

### 1. Place JAR Files

Copy your JAR files to the `java-apps/jars/` directory:
```powershell
cp your-app.jar java-apps/jars/
```

### 2. Create DAG for Your Application

Create a new DAG file in the `dags/` directory:
```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

dag = DAG(
    'your_java_app_dag',
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily'
)

run_java_task = BashOperator(
    task_id='run_your_java_app',
    bash_command='java -jar /opt/airflow/java-apps/jars/your-app.jar',
    dag=dag
)
```

### 3. Restart Services (if needed)

After adding new files, you may need to restart:
```powershell
docker-compose -f docker/docker-compose.yml restart
```

## Troubleshooting

### Services Won't Start

1. Check Docker Desktop is running
2. Ensure ports 8080 and 5432 are not in use
3. Check logs: `docker-compose -f docker/docker-compose.yml logs`

### Java Not Found

1. Rebuild the image: `docker-compose -f docker/docker-compose.yml build --no-cache`
2. Check Java installation in container:
   ```powershell
   docker-compose -f docker/docker-compose.yml exec airflow-webserver java -version
   ```

### Memory Issues

1. Increase Docker Desktop memory allocation (8GB+ recommended)
2. Adjust JVM memory settings in `.env` file:
   ```
   JAVA_OPTS=-Xms256m -Xmx1g -XX:+UseG1GC
   ```

### Permission Issues

1. Check container permissions:
   ```powershell
   docker-compose -f docker/docker-compose.yml exec airflow-webserver ls -la /opt/airflow/java-apps
   ```

## Stopping Services

To stop all services:
```powershell
docker-compose -f docker/docker-compose.yml down
```

To stop and remove volumes (clears all data):
```powershell
docker-compose -f docker/docker-compose.yml down -v
```

## Next Steps

1. **Customize** the Java environment for your specific needs
2. **Add** your Java applications to the `java-apps/` directory
3. **Create** DAGs for your specific workflows
4. **Configure** monitoring and alerting as needed
5. **Scale** using Kubernetes or Celery executor for production

For more advanced configurations, refer to the individual component documentation and the main README.md file.
