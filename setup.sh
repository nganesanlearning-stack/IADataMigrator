#!/bin/bash
# Quick setup script for Airflow with Java

echo "🚀 Setting up Apache Airflow with Java Environment"
echo "=================================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"

# Build the custom image
echo "🔨 Building custom Airflow image with Java..."
docker-compose build

if [ $? -eq 0 ]; then
    echo "✅ Image built successfully"
else
    echo "❌ Failed to build image"
    exit 1
fi

# Start services
echo "🚢 Starting Airflow services..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo "✅ Services started successfully"
else
    echo "❌ Failed to start services"
    exit 1
fi

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check Java environment
echo "☕ Testing Java environment..."
docker-compose exec -T airflow-scheduler java -version

echo ""
echo "🎉 Setup Complete!"
echo "==================="
echo "📊 Airflow UI: http://localhost:8080"
echo "   Username: airflow"
echo "   Password: airflow"
echo ""
echo "🗄️  PgAdmin: http://localhost:5050"
echo "   Email: admin@admin.com"
echo "   Password: admin"
echo ""
echo "🌸 Flower (optional): docker-compose --profile flower up"
echo "   URL: http://localhost:5556"
echo ""
echo "🔍 Check logs: docker-compose logs -f"
echo "🛑 Stop all: docker-compose down"
