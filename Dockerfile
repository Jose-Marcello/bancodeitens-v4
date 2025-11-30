#------------------------------------------------------------------
# Estágio 1: Build da Aplicação ASP.NET Core (BUILD)
#------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# 1. Copia todos os arquivos (Já fizemos este commit)
COPY . .

# 2. NOVO PASSO CRUCIAL: Limpa as pastas de cache de build locais.
# Isso garante que o 'dotnet restore' e 'dotnet publish' rodem em um estado limpo,
# sem arquivos 'obj' ou 'bin' antigos que podem confundir o compilador.
RUN find . -type d -name "obj" -exec rm -rf {} + && \
    find . -type d -name "bin" -exec rm -rf {} +

# 3. Restaura e Publica TUDO em um único comando
# A flag /p:RestorePackagesPath força o NuGet a usar um cache específico,
# mas vamos tentar a forma mais simples primeiro:
RUN dotnet publish "src/BancoItens.Api/BancoItens.Api.csproj" -c Release -o /publish /p:UseAppHost=false /p:RuntimeIdentifier=linux-x64

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