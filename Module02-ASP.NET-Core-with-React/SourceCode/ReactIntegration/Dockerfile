# Build stage for React app
FROM node:18.18.0-alpine AS client-build
WORKDIR /src/client-app
COPY client-app/package*.json ./
RUN npm ci --only=production
COPY client-app/ .
RUN npm run build

# Build stage for .NET app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ReactIntegration.csproj", "."]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

# Final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443
COPY --from=publish /app/publish .
COPY --from=client-build /src/wwwroot ./wwwroot
ENTRYPOINT ["dotnet", "ReactIntegration.dll"]