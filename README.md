# Quick Start Guide - Airflow + Java JDK 21

## 🚀 One-Click Setup

### For Linux/macOS:
```bash
chmod +x quick-setup.sh
./quick-setup.sh
```

### For Windows:
```cmd
quick-setup.bat
```

## ✅ Verify Installation

### For Linux/macOS:
```bash
chmod +x verify-installation.sh
./verify-installation.sh
```

### For Windows:
```cmd
verify-installation.bat
```

## 📱 Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| **Airflow Web UI** | http://localhost:9580 | admin/admin |
| **PgAdmin** | http://localhost:9550 | admin@admin.com/admin |
| **PostgreSQL** | localhost:9532 | airflow/airflow |

## 🧪 Quick Tests

### Test Java Version:
```bash
docker exec javaairflow-airflow-webserver-1 java -version
```

### Test Maven:
```bash
docker exec javaairflow-airflow-webserver-1 mvn --version
```

### Test Java App:
```bash
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps SimpleJavaApp
```

### Compile Java Code:
```bash
docker exec javaairflow-airflow-webserver-1 javac -cp /opt/airflow/java-apps /opt/airflow/java-apps/DataValidator.java
```

## 🔧 Common Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart specific service
docker-compose restart airflow-webserver

# Enter container
docker exec -it javaairflow-airflow-webserver-1 bash

# Check container status
docker-compose ps
```

## 📁 Project Structure

```
javaairflow/
├── docker-compose.yaml     # Main orchestration file
├── Dockerfile             # Java JDK 21 + Maven setup
├── dags/                  # Airflow DAGs
├── java-apps/             # Java applications
├── config/                # Configuration files
├── quick-setup.sh/.bat    # Automated setup scripts
├── verify-installation.sh/.bat  # Verification scripts
└── DEPLOYMENT_GUIDE.md    # Detailed setup guide
```

## 🆘 Troubleshooting

### Build Fails:
```bash
docker system prune -a
docker-compose build --no-cache
```

### Port Conflicts:
Edit `docker-compose.yaml` and change port mappings

### Permission Issues:
```bash
sudo chown -R $USER:$USER ./javaairflow
```

### Check Logs:
```bash
docker-compose logs airflow-webserver
```

## 📚 Full Documentation

See `DEPLOYMENT_GUIDE.md` for complete setup instructions and troubleshooting.
   ```powershell
   docker-compose up -d
   ```

3. **Access your services:**
   - **Airflow UI**: http://localhost:8080 (username: airflow, password: airflow)
   - **PgAdmin**: http://localhost:5050 (email: admin@admin.com, password: admin)
   - **Flower** (optional): `docker-compose --profile flower up` then http://localhost:5556

4. **Verify Java environment:**
   ```powershell
   docker-compose exec airflow-scheduler java -version
   ```

## Features

- Apache Airflow 3.0.2 with Java 17 support
- CeleryExecutor with Redis and PostgreSQL  
- PgAdmin for database management
- Flower for Celery monitoring (optional)
- Custom Docker image with optimized Java runtime
- Persistent volumes for Java applications and logs
- Example DAGs demonstrating Java integration
- Health checks and monitoring setup
- Maven for Java project builds

## Testing Java Integration

### 1. Enable Example DAG

1. Go to the Airflow UI (http://localhost:8080)
2. Find the `java_example_dag` in the DAGs list
3. Toggle it on by clicking the switch
4. Click on the DAG to view its tasks

### 2. Manual Java Testing

Execute Java commands directly in any container:
```powershell
# Access the scheduler container
docker-compose exec airflow-scheduler bash

# Inside the container, test Java
java -version
cd /opt/airflow/java-apps
javac DataProcessor.java
java DataProcessor input.txt output.txt
```

## Adding Your Java Applications

### 1. Place JAR Files
```powershell
# Copy your JAR files to the java-apps/jars/ directory
cp your-app.jar java-apps/jars/
```

### 2. Create DAG for Your Application
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
```powershell
docker-compose restart
```
