#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80

RUN useradd -rm -d /home/dotnetuser -s /bin/bash -g root -G sudo -u 1001 dotnetuser
WORKDIR /data
RUN chown -R dotnetuser /data
USER dotnetuser

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY ["file-upload-and-unzip-with-docker.csproj", "."]
RUN dotnet restore "./file-upload-and-unzip-with-docker.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "file-upload-and-unzip-with-docker.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "file-upload-and-unzip-with-docker.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "file-upload-and-unzip-with-docker.dll"]
