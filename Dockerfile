#------------------------------------------------------------------
# Estágio 1: Build da Aplicação ASP.NET Core (BUILD)
#------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# 1. Cria o diretório para cache NuGet
RUN mkdir -p /nuget_cache

# 2. Copia a Solution e os Projetos para o cache de layer
COPY BancoDeItens_V3.sln .
COPY src/ src/

# 3. Restaura explicitamente e FORÇADAMENTE (Ignorando cache e baixando tudo)
RUN dotnet restore BancoDeItens_V3.sln \
    /p:RestorePackagesPath=/nuget_cache \
    /p:RestoreForce=true

# 4. Publica apenas o projeto da API, usando os pacotes restaurados.
# Usamos --no-restore para que ele utilize os pacotes que acabamos de baixar.
RUN dotnet publish "src/BancoItens.Api/BancoItens.Api.csproj" \
    -c Release -o /publish \
    /p:UseAppHost=false \
    /p:RuntimeIdentifier=linux-x64 \
    --no-restore

#------------------------------------------------------------------
# Estágio 2: Imagem de Produção Final (RUNTIME)
#------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080

# Copia os arquivos publicados
COPY --from=build /publish .

# Comando final para rodar a aplicação
CMD ["dotnet", "BancoItens.Api.dll", "--urls", "http://0.0.0.0:8080"]