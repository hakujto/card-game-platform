FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
COPY . .
RUN dotnet publish src/cards_project.fsproj -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out .
COPY src/schema.sql .
ENV ASPNETCORE_URLS=http://+:5000
ENTRYPOINT ["dotnet", "CardsProject.dll"]
