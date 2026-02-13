# Setup Instructions for Another Machine

## 📋 Quick Setup Checklist

### Prerequisites
- [ ] Docker Desktop installed
- [ ] Docker Compose available
- [ ] 8GB+ RAM recommended
- [ ] Ports 9580, 9550, 9532 available

### Step-by-Step Setup

#### 1. Copy Project Files
Copy the entire `javaairflow` folder to your target machine with all subdirectories.

#### 2. Navigate to Directory
```bash
cd /path/to/javaairflow
```

#### 3. Run Setup Script

**For Windows:**
```cmd
quick-setup.bat
```

**For Linux/macOS:**
```bash
chmod +x quick-setup.sh
./quick-setup.sh
```

#### 4. Verify Installation

**For Windows:**
```cmd
verify-installation.bat
```

**For Linux/macOS:**
```bash
chmod +x verify-installation.sh
./verify-installation.sh
```

#### 5. Manual Setup (Alternative)

If scripts don't work, run manually:

```bash
# Build images
docker-compose build --no-cache

# Start services
docker-compose up -d

# Check status
docker-compose ps

# Test Java
docker exec javaairflow-airflow-webserver-1 java -version
docker exec javaairflow-airflow-webserver-1 mvn --version
```

## ✅ Verification Results

Your setup should show:

### Container Status:
- ✅ All containers running and healthy
- ✅ Webserver accessible on port 9580

### Java Environment:
- ✅ **Java**: OpenJDK 21.0.8 LTS (Eclipse Temurin)
- ✅ **Maven**: Apache Maven 3.9.9
- ✅ **JVM Options**: Optimized for Java 21

### Application Tests:
- ✅ **SimpleJavaApp**: Executes successfully
- ✅ **DataProcessor**: Processes CSV files
- ✅ **Output Files**: Created in `/opt/airflow/data/`

## 🌐 Access Information

| Component | URL/Connection | Credentials |
|-----------|----------------|-------------|
| **Airflow Web UI** | http://localhost:9580 | admin / admin |
| **PgAdmin** | http://localhost:9550 | admin@admin.com / admin |
| **PostgreSQL** | localhost:9532 | airflow / airflow |

## 🧪 Sample Execution Commands

### Test Java Version:
```bash
docker exec javaairflow-airflow-webserver-1 java -version
```
**Expected Output:**
```
openjdk version "21.0.8" 2025-07-15 LTS
OpenJDK Runtime Environment Temurin-21.0.8+9 (build 21.0.8+9-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.8+9 (build 21.0.8+9-LTS, mixed mode, sharing)
```

### Test Maven:
```bash
docker exec javaairflow-airflow-webserver-1 mvn --version
```
**Expected Output:**
```
Apache Maven 3.9.9 (8e8579a9e76f7d015ee5ec7bfcdc97d260186937)
Maven home: /opt/maven
Java version: 21.0.8, vendor: Eclipse Adoptium
```

### Run Java Application:
```bash
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps SimpleJavaApp
```

### Process Data:
```bash
docker exec javaairflow-airflow-webserver-1 mkdir -p /opt/airflow/data
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps DataProcessor /opt/airflow/java-apps/sample_data.csv /opt/airflow/data/output.csv
```

### Compile Java Code:
```bash
docker exec javaairflow-airflow-webserver-1 javac -cp /opt/airflow/java-apps /opt/airflow/java-apps/DataValidator.java
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps DataValidator
```

### Build with Maven:
```bash
docker exec -it javaairflow-airflow-webserver-1 bash
cd /opt/airflow/java-apps
mvn clean compile package
```

## 🔧 Common Management Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart airflow-webserver

# View logs
docker-compose logs -f airflow-webserver
docker-compose logs -f airflow-scheduler

# Check container status
docker-compose ps

# Enter container shell
docker exec -it javaairflow-airflow-webserver-1 bash

# Clean restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 🆘 Troubleshooting

### Build Issues:
```bash
# Clean Docker system
docker system prune -a

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Port Conflicts:
Edit `docker-compose.yaml` and change port mappings:
```yaml
ports:
  - "8080:8080"  # Change first port number
```

### Permission Issues (Linux/macOS):
```bash
sudo chown -R $USER:$USER ./javaairflow
chmod -R 755 ./javaairflow
```

### Memory Issues:
Increase Docker memory allocation to 8GB+ in Docker Desktop settings.

## 📊 Performance Monitoring

### Check Resource Usage:
```bash
docker stats
```

### Check Java Memory:
```bash
docker exec javaairflow-airflow-webserver-1 java -XX:+PrintFlagsFinal -version | grep HeapSize
```

### View JVM Options:
```bash
docker exec javaairflow-airflow-webserver-1 cat /opt/airflow/java-apps/configs/jvm.options
```

## 🚀 Next Steps

1. **Access Airflow**: Open http://localhost:9580
2. **Explore DAGs**: Check available Java-related workflows
3. **Create Custom DAGs**: Add your Java applications
4. **Monitor Execution**: Use Airflow UI for task monitoring
5. **Scale**: Modify docker-compose.yaml for production needs

## 📚 Additional Resources

- **Full Guide**: `DEPLOYMENT_GUIDE.md`
- **Project Structure**: Check `README.md`
- **Configuration**: Review `docker-compose.yaml` and `Dockerfile`
- **Scripts**: Use automation scripts for maintenance
