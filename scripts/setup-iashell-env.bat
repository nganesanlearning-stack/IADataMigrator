@echo off
REM Setup iashell environment inside Airflow container (Windows batch version)
REM This script ensures iashell has proper Java environment and permissions

echo Setting up iashell environment...

REM Define paths
set IASHELL_HOME=/opt/airflow/java-apps/iashell/iashell
set IASHELL_BIN=%IASHELL_HOME%/bin
set JAVA_HOME=/opt/java/temurin-21

REM Print current Java environment
echo === Java Environment Information ===
echo JAVA_HOME: %JAVA_HOME%
echo Java Version:
%JAVA_HOME%/bin/java -version

echo Java Path: %JAVA_HOME%/bin/java
echo Classpath for iashell: %IASHELL_HOME%/lib/infoarchive-shell-25.2-exec.jar

REM Test iashell execution
echo === Testing iashell execution ===
echo Running iashell version check...

cd %IASHELL_BIN%
REM Run iashell with version or help command to test if it works
%IASHELL_BIN%/iashell.bat --help

echo === iashell Environment Setup Complete ===
echo iashell binary location: %IASHELL_BIN%/iashell
echo iashell.bat location: %IASHELL_BIN%/iashell.bat
echo Java executable: %JAVA_HOME%/bin/java
echo iashell home: %IASHELL_HOME%
