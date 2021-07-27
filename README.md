# WatchAndAssist
 An application that can be configured to watch and assist

# Requirements

You need to have the following installed on your machine.

1. sqllite3
2. Windows PowerShell
3. Java (required for Apache Tomcat)
4. Apache Tomcat 

# Installation

Perform the following steps to perform the installation

1. Navigate to the Setup folder.
2. Run the script generateMainPage.ps1
3. Install an instance of Apache Tomcat
4. Copy the main.jsp file to the webapps/watcher folder.
5. Copy the watcher folder to the Apache Tomcat webapps folder.
6. Navigate to the worker folder.
7. Install the checkRequests.ps1 script as a service
*Recommended that you use the Non-Sucking Service Manager located at https://nssm.cc/*

# Setup of Database

Perform the following and setup the database

1. Navigate to sqllite or download sqllite3.
2. Run the command sqllite3 *database*
3. Navigate to the setup folder.
4. Run the commands in the Setup.txt file.

# Running

Perform the following to run the webapp

1. Start Apache Tomcat or install it
2. Navigate to http://localhost:8080/watcher/main.jsp
3. Navigate to the links and a request will be sent to the worker
4. Refresh the page until you see the results of your request
