#!/bin/bash
# Script to verify Java and Maven installation

echo "===== Java Environment Check ====="
echo "Java version:"
java -version
echo ""

echo "JAVA_HOME:"
echo $JAVA_HOME
echo ""

echo "===== Maven Environment Check ====="
echo "Maven version:"
mvn -version
echo ""

echo "MAVEN_HOME:"
echo $MAVEN_HOME
echo ""

echo "===== PATH Variable ====="
echo $PATH
echo ""

echo "===== Environment Variables ====="
env | grep -E "JAVA|MAVEN"
echo ""

echo "===== Binary Locations ====="
which java
which mvn
