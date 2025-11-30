#------------------------------------------------------------------
# Estágio 1: Build da Aplicação ASP.NET Core (BUILD)
#------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# 1. Copia todos os arquivos e pastas da raiz do projeto para o container.
# Esta é a mudança mais crucial para soluções multi-projeto:
# Garante que o .sln, o NuGet.config e *toda* a pasta src/ (com todos os .csproj)
# estejam na hierarquia correta em /app antes da restauração.
COPY . .

# 2. Restaura explicitamente a Solução.
# Isso garante que as dependências NuGet (AutoMapper, FluentValidation, etc.) sejam baixadas
# e que todas as referências entre projetos (Project References) sejam resolvidas.
RUN dotnet restore BancoDeItens_V3.sln

# 3. Publica a Solução focando no projeto de API.
# O path é relativo ao WORKDIR /app.
RUN dotnet publish "src/BancoItens.Api/BancoItens.Api.csproj" -c Release -o /publish /p:UseAppHost=false /p:RuntimeIdentifier=linux-x64

#------------------------------------------------------------------
# Estágio 2: Imagem de Produção Final (RUNTIME)
#------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080

# Copia os arquivos publicados do estágio 'build'
COPY --from=build /publish .

# Comando final para rodar a aplicação
CMD ["dotnet", "BancoItens.Api.dll", "--urls", "http://0.0.0.0:8080"]