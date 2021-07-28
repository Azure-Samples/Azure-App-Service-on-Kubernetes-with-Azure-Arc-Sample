#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0
ARG BUILDTIME_CONNECTION_STRING
ENV ApplicationInsights__ConnectionString=$BUILDTIME_CONNECTION_STRING
EXPOSE 80
EXPOSE 443

COPY Publish .
ENTRYPOINT ["dotnet", "Ratings.Server.dll"]