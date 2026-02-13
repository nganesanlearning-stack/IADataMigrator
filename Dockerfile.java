# Multi-stage build to ensure Java installation
FROM eclipse-temurin:21-jdk-alpine as java-base

# Add Maven stage
FROM maven:3.9-eclipse-temurin-21-alpine as maven-base

FROM apache/airflow:3.0.2

# Switch to root user for package installation
USER root

# Copy Java from the java-base stage
COPY --from=java-base /opt/java/openjdk /opt/java/openjdk

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$PATH:$JAVA_HOME/bin

# Copy Maven from the maven-base stage
COPY --from=maven-base /usr/share/maven /usr/share/maven
ENV MAVEN_HOME=/usr/share/maven
ENV PATH=$PATH:$MAVEN_HOME/bin

# Create directories for Java applications
RUN mkdir -p /opt/airflow/java-apps && \
    chmod 755 /opt/airflow/java-apps

# Switch back to airflow user
USER airflow

# Install Python packages if needed
RUN pip install --no-cache-dir \
    py4j \
    jaydebeapi
