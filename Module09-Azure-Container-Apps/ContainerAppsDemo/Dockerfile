# Simple Dockerfile for Azure Container Apps
# This file is used by Azure Container Registry to build your image in the cloud
# You don't need Docker installed locally!

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .

# Azure Container Apps sets the PORT environment variable
EXPOSE 80

ENTRYPOINT ["dotnet", "ContainerAppsDemo.dll"]