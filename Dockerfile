FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS base
WORKDIR /app
EXPOSE 5000
 
ENV ASPNETCORE_URLS=http://+:5000
 
# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser
 
FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
WORKDIR /src
COPY ["consumeapi.csproj", "./"]
RUN dotnet restore "consumeapi.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "consumeapi.csproj" -c Release -o /app/build
 
FROM build AS publish
RUN dotnet publish "consumeapi.csproj" -c Release -o /app/publish
 
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "consumeapi.dll"]