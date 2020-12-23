---
page_type: sample
description: "Deploy containerized dotnet application using GitHub Actions"
products:
- GitHub Actions
- Azure App service
- Azure SQL Database
languages:
- dotnet
---

# Containerized ASP.NET Core and SQL Database for GitHub Actions

This is repo contains a sample ASP.NET Core application which uses an Azure SQL database as backend. The web app is containerized and deployed to Azure Web Apps for Containers using by using GitHub Actions.

For all samples to set up GitHub workflows, see [Create your first workflow](https://github.com/Azure/actions-workflow-samples)

The sample source code is based in the tutorial for building [ASP.NET Core and Azure SQL Database app in App Services](https://docs.microsoft.com/azure/app-service/containers/tutorial-dotnetcore-sqldb-app). 

## Steps to create an end-to-end CI/CD workflow

This repo contains two different GitHub workflows:
* [Create Azure Resources](.github/workflows/azuredeploy.yaml): To create the Azure Resources required for the sample by using an ARM template. This workflow will create the following resources:
    - App Service Plan (Linux).
    - Web App for Containers (with one staging slot)
    - Azure Container Registry.
    - Azure SQL Server and the Azure SQL Database for the sample.
    - Storage Account.
* [Build image, push & deploy](.github/workflows/build-deploy.yaml): this workflow will build the sample app using a container, push the container to the Azure Container Registry, deploy the container to the Web App staging slot, deploy or update the database and, finally, swap the slots.

To start, you can fork directly this repo and follow the instructions to properly setup the workflows.

### Pre-requisites
The [Create Azure Resources](.github/workflows/azuredeploy.yaml) workflow, describes in the `azuredeploy.yaml` file the pre-requisites needed to setup the CI/CD.

### 1. Create the Azure Resource group
Open the Azure Cloud Shell at https://shell.azure.com. You can alternately use the Azure CLI if you've installed it locally. (For more information on Cloud Shell, see the [Cloud Shell Overview](https://docs.microsoft.com/en-us/azure/cloud-shell/overview))   

``` cmd
az group create --name {resource-group-name} --location {resource-group-location}
```
Replace the `{resource-group-name}` and the `{resource-group-location}` for one of your preferences. By default, the resource group name used in the .yaml workflows is `rg-todo-sample`, be sure to replace it if you change the name.

Sample:
```
az group create --name rg-todo-sample --location westeurope
```
### 2. Create a Service Principal to manage your resource group from GitHub Actions
We will use a service principal from the GitHub workflow to be able to create the resources and make the deployments.

```
az ad sp create-for-rbac --name "{service-principal-name}" --sdk-auth --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}
```

The `{service-principal-name}` is the name you want to provide. You can find `{subscription-id}` in the Azure Portal where you have created the resource group. Finally, the `{resource-group-name}` is the name provided in the previous command.

Sample:
```
az ad sp create-for-rbac --name "sp-todo-app" --sdk-auth --role contributor --scopes /subscriptions/00000000-0000-aaaa-bbbb-00000000/resourceGroups/rg-todo-sample
```

Save the command output as it will be used to setup the required `AZURE_CREDENTIALS` secret in following step.
```
{
  "clientId": "<guid>",
  "clientSecret": "<secret>",
  "subscriptionId": "00000000-0000-aaaa-bbbb-00000000",
  "tenantId": ""00000000-0000-cccc-dddd-00000000"",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}

```
For further details, check https://github.com/Azure/login#configure-deployment-credentials

### 3. Configure the required secrets 
Add the following secrets to your repo:
- AZURE_CREDENTIALS: the content is the output of the previous executed command.
- SQL_SERVER_ADMIN_PASSWORD: this will be the password used to setup and access the Azure SQL database.

For further deatils, check https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository

Finally, be sure that in both workflows, the variables have the correct values and matches the pre-requistes setup you just setup.

### 4. Execute the Create Resources worklfow
 Go to your repo [Actions](/actions) tab, under *All workflows* you will see the [Create Azure Resources](/actions?query=workflow%3A"Create+Azure+Resources") workflow. 

Launch the worflow by using the *[workflow_dispatch](https://github.blog/changelog/2020-07-06-github-actions-manual-triggers-with-workflow_dispatch/)* event trigger.

This will create all the required resources in the Azure Subscritption and Resource Group you configured.

## Test your CI/CD workflow
To lauch the CI/CD workflow (Build image, push & deploy), you just need to make a change in the app code. You will see a new GitHub action initiated in the [Actions](/actions) tab.

## Workflows yaml explained

