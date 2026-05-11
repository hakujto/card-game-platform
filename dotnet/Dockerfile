FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app
COPY CardsProject/CardsProject.csproj CardsProject/
RUN dotnet restore CardsProject/CardsProject.csproj
COPY . .
RUN dotnet publish CardsProject/CardsProject.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/out .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
CMD ["dotnet", "CardsProject.dll"]
