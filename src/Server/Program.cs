using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Serilog;
using Serilog.Events;
using System;

namespace Ratings.Server
{
    public class Program
    {

        public static void Main(string[] args)
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Information()
                .MinimumLevel.Override("Serilog", LogEventLevel.Information)
                .WriteTo.File("Logs/Example.txt")
                .CreateLogger();

            try
            {
                Log.Logger.Information("Running host");
                CreateHostBuilder(args).Build().Run();
            }
            catch (Exception e)
            {
                Log.Logger.Error("Runing host error", e);
            }

        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    try
                    {
                        webBuilder.UseStartup<Startup>();
                    } catch (Exception e)
                    {
                        Log.Logger.Error("Startup error", e);
                    }
                });
    }
}

