# Quick setup script for Airflow with Java (PowerShell version)

Write-Host "🚀 Setting up Apache Airflow with Java Environment" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Build the custom image
Write-Host "🔨 Building custom Airflow image with Java..." -ForegroundColor Yellow
docker-compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to build image" -ForegroundColor Red
    exit 1
}

# Start services
Write-Host "🚢 Starting Airflow services..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Services started successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start services" -ForegroundColor Red
    exit 1
}

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check Java environment
Write-Host "☕ Testing Java environment..." -ForegroundColor Yellow
docker-compose exec -T airflow-scheduler java -version

Write-Host ""
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host "📊 Airflow UI: http://localhost:8080" -ForegroundColor Cyan
Write-Host "   Username: airflow" -ForegroundColor White
Write-Host "   Password: airflow" -ForegroundColor White
Write-Host ""
Write-Host "🗄️  PgAdmin: http://localhost:5050" -ForegroundColor Cyan
Write-Host "   Email: admin@admin.com" -ForegroundColor White
Write-Host "   Password: admin" -ForegroundColor White
Write-Host ""
Write-Host "🌸 Flower (optional): docker-compose --profile flower up" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:5556" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Check logs: docker-compose logs -f" -ForegroundColor Magenta
Write-Host "🛑 Stop all: docker-compose down" -ForegroundColor Magenta
