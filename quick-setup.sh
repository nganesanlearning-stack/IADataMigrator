#!/bin/bash

# Quick Setup Script for Airflow + Java JDK 21
# Run this script on the target machine after copying the project files

set -e  # Exit on any error

echo "🚀 Starting Airflow + Java JDK 21 Setup..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists docker; then
    echo "❌ Docker not found. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command_exists docker-compose; then
    echo "❌ Docker Compose not found. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose found"

# Display versions
echo "🔍 Versions:"
docker --version
docker-compose --version

# Check if we're in the right directory
if [ ! -f "docker-compose.yaml" ]; then
    echo "❌ docker-compose.yaml not found. Please run this script from the javaairflow directory."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker-compose down 2>/dev/null || true

# Clean up old images (optional)
read -p "🧹 Do you want to clean up old Docker images? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Cleaning up Docker system..."
    docker system prune -f
fi

# Build images
echo "🔨 Building Docker images (this may take several minutes)..."
docker-compose build --no-cache

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Check status
echo "📊 Checking service status..."
docker-compose ps

# Test Java installation
echo "☕ Testing Java JDK 21 installation..."
docker exec javaairflow-airflow-webserver-1 java -version

echo "🔧 Testing Maven installation..."
docker exec javaairflow-airflow-webserver-1 mvn --version

# Test Java application
echo "🧪 Testing Java application execution..."
docker exec javaairflow-airflow-webserver-1 mkdir -p /opt/airflow/data
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps SimpleJavaApp

# Test data processor
echo "📊 Testing data processor..."
docker exec javaairflow-airflow-webserver-1 java -cp /opt/airflow/java-apps DataProcessor /opt/airflow/java-apps/sample_data.csv /opt/airflow/data/test_output.csv

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "📱 Access Points:"
echo "   Airflow Web UI: http://localhost:9580 (admin/admin)"
echo "   PgAdmin:        http://localhost:9550 (admin@admin.com/admin)"
echo "   PostgreSQL:     localhost:9532 (airflow/airflow)"
echo ""
echo "🔧 Common Commands:"
echo "   View logs:      docker-compose logs -f"
echo "   Stop services:  docker-compose down"
echo "   Restart:        docker-compose restart"
echo "   Enter container: docker exec -it javaairflow-airflow-webserver-1 bash"
echo ""
echo "📚 For detailed documentation, see DEPLOYMENT_GUIDE.md"
