#!/bin/bash
# Test script for Java 21 installation

echo "=== Java 21 Installation Test ==="
echo

echo "1. Testing Java version:"
docker-compose -f docker-compose-fixed.yaml exec airflow-apiserver java -version
echo

echo "2. Testing Maven version:"
docker-compose -f docker-compose-fixed.yaml exec airflow-apiserver mvn -version
echo

echo "3. Testing Java environment variables:"
docker-compose -f docker-compose-fixed.yaml exec airflow-apiserver bash -c "echo JAVA_HOME: \$JAVA_HOME"
docker-compose -f docker-compose-fixed.yaml exec airflow-apiserver bash -c "echo MAVEN_HOME: \$MAVEN_HOME"
echo

echo "4. Testing Java compilation:"
docker-compose -f docker-compose-fixed.yaml exec airflow-apiserver bash -c "cd /opt/airflow/java-apps && echo 'public class Test { public static void main(String[] args) { System.out.println(\"Java 21 is working!\"); } }' > Test.java && javac Test.java && java Test"
echo

echo "5. Testing Maven compilation:"
docker-compose -f docker-compose-fixed.yaml exec airflow-apiserver bash -c "cd /opt/airflow/java-apps && mvn clean compile"
echo

echo "=== Test Complete ==="
