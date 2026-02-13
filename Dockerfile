# Multi-stage Dockerfile using official Eclipse Temurin image (most reliable)
FROM eclipse-temurin:21-jdk-jammy as jdk-source

# Maven stage - use official Maven image with Java 21
FROM maven:3.9-eclipse-temurin-21-jammy as maven-source

# Main Airflow image
FROM apache/airflow:3.0.2

USER root

# Copy JDK 21 from the official Temurin image
COPY --from=jdk-source /opt/java/openjdk /opt/java/temurin-21

# Copy Maven from the official Maven image
COPY --from=maven-source /usr/share/maven /opt/maven

# Set Java environment variables
ENV JAVA_HOME=/opt/java/temurin-21
ENV PATH=$JAVA_HOME/bin:$PATH

# Set Maven environment variables
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# Create directories for Java applications
RUN mkdir -p /opt/airflow/java-apps/{jars,libs,configs,logs} && \
    chown -R airflow:root /opt/airflow/java-apps && \
    chmod -R 775 /opt/airflow/java-apps

# Create JVM options file for Java applications
RUN echo '-Xms512m' > /opt/airflow/java-apps/configs/jvm.options && \
    echo '-Xmx2g' >> /opt/airflow/java-apps/configs/jvm.options && \
    echo '-XX:+UseG1GC' >> /opt/airflow/java-apps/configs/jvm.options && \
    echo '-XX:MaxGCPauseMillis=200' >> /opt/airflow/java-apps/configs/jvm.options && \
    echo '-XX:+UseStringDeduplication' >> /opt/airflow/java-apps/configs/jvm.options && \
    echo '-Djava.awt.headless=true' >> /opt/airflow/java-apps/configs/jvm.options && \
    echo '-Dfile.encoding=UTF-8' >> /opt/airflow/java-apps/configs/jvm.options && \
    chown airflow:root /opt/airflow/java-apps/configs/jvm.options && \
    chmod 664 /opt/airflow/java-apps/configs/jvm.options

# Switch back to airflow user
USER airflow

# Install additional Python packages for Java integration
RUN pip install --no-cache-dir \
    py4j==0.10.9.7 \
    jaydebeapi==1.2.3

# Verify Java and Maven installation
RUN java -version && javac -version && mvn --version
