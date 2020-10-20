#!/bin/bash
if [ "$ConnectionStrings__MyDbConnection" = "" ]
    then
        echo "No connection string set. Ensure the environment variable ConnectionStrings__MyDbConnection is set with the connection string to the database."
    else
        echo "Connection string set to: " $ConnectionStrings__MyDbConnection
fi

echo "Building the container..."
docker build -t todo-sample:latest .
echo

echo "Running the container (interactive)..."
docker run -p 5000:5000 -p:5001:5001 --env ConnectionStrings__MyDbConnection --name todo-sample-app todo-sample
echo

echo "Prune the container"
docker container prune -f