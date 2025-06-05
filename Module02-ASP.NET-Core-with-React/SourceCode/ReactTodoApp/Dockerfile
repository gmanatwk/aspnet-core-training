# Multi-stage build for ASP.NET Core with React
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# Create non-root user for security
RUN addgroup --system --gid 1000 appgroup \
    && adduser --system --uid 1000 --ingroup appgroup --shell /bin/false appuser

FROM node:20.11.0-alpine AS node-build
WORKDIR /src/ClientApp

# Copy package files and install dependencies
COPY ClientApp/package*.json ./
RUN npm ci

# Copy source code and build
COPY ClientApp/ ./
RUN npm run build

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["ReactTodoApp.csproj", "."]
RUN dotnet restore "./ReactTodoApp.csproj"

# Copy source code
COPY . .

# Copy built React app from node-build stage
COPY --from=node-build /src/ClientApp/dist ./ClientApp/dist

# Build the application
RUN dotnet build "ReactTodoApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ReactTodoApp.csproj" -c Release -o /app/publish /p:UseAppHost=false /p:SkipNpmBuild=true

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
# Copy React build files to wwwroot
COPY --from=node-build /src/ClientApp/dist ./wwwroot
USER appuser
ENTRYPOINT ["dotnet", "ReactTodoApp.dll"]
