FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["DNAQMSAPI/DNAQMSAPI.Api/DNAQMSAPI.Api.csproj", "DNAQMSAPI/DNAQMSAPI.Api/"]
COPY ["DNAQMSAPI/DNAQMSAPI.Application/DNAQMSAPI.Application.csproj", "DNAQMSAPI/DNAQMSAPI.Application/"]
COPY ["DNAQMSAPI/DNAQMSAPI.Domain/DNAQMSAPI.Domain.csproj", "DNAQMSAPI/DNAQMSAPI.Domain/"]
COPY ["DNAQMSAPI/DNAQMSAPI.Infrastructure/DNAQMSAPI.Infrastructure.csproj", "DNAQMSAPI/DNAQMSAPI.Infrastructure/"]
COPY ["DNAQMSAPI/DNAQMSAPI.Security/DNAQMSAPI.Security.csproj", "DNAQMSAPI/DNAQMSAPI.Security/"]
COPY ["DNAQMSAPI/DNAQMSAPI.Shared/DNAQMSAPI.Shared.csproj", "DNAQMSAPI/DNAQMSAPI.Shared/"]
COPY ["DNAQMSAPI/DNAQMSAPI.Payments/DNAQMSAPI.Payments.csproj", "DNAQMSAPI/DNAQMSAPI.Payments/"]
COPY ["DNAQMSAPI/DNAQMSAPI.Storage/DNAQMSAPI.Storage.csproj", "DNAQMSAPI/DNAQMSAPI.Storage/"]
COPY ["AntiGravity.Enterprise.Shared.Core/AntiGravity.Enterprise.Shared.Core.csproj", "AntiGravity.Enterprise.Shared.Core/"]

RUN dotnet restore "DNAQMSAPI/DNAQMSAPI.Api/DNAQMSAPI.Api.csproj"
COPY . .
WORKDIR "/src/DNAQMSAPI/DNAQMSAPI.Api"
RUN dotnet build "DNAQMSAPI.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DNAQMSAPI.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DNAQMSAPI.Api.dll"]
