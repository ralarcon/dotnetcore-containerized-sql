#!/bin/bash
containerRegistryName="todosampleacr" #TODO: set your container registry name
containerRegistryUser="$containerRegistryName"
azureContainerRegistry="$containerRegistryName.azurecr.io"
containerPassword=$(az acr credential show --resource-group todo-sample-rsg --name $containerRegistryName --query passwords[0].value -o tsv)

echo "Build image and push to $azureContainerRegistry"

echo "Building the container..."
docker build -t todo-sample:latest .
echo

echo "Tagging for azure container registry"
docker tag todo-sample $azureContainerRegistry/todo-sample:latest
echo

echo "Push image"
docker push $azureContainerRegistry/todo-sample:latest
echo

echo "Repositories in the container registry"
az acr repository list -n $containerRegistryName
