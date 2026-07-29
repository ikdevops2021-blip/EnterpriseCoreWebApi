using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using MySqlConnector;

namespace SeederApp
{
    class Program
    {
        static async Task<int> Main(string[] args)
        {
            Console.WriteLine("==================================================================");
            Console.WriteLine("  ENTERPRISE CORE WEB API - SEEDER & MIGRATION ENGINE CLI  ");
            Console.WriteLine("==================================================================");

            // 1. Build Configuration
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile("../DNAQMSAPI/DNAQMSAPI.API/appsettings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .AddCommandLine(args);

            var config = builder.Build();

            // 2. Determine Database Provider and Connection String
            string provider = GetArgValue(args, "--provider") ?? config["DatabaseSettings:Databases:0:Type"] ?? "MySql";
            string connStr = GetArgValue(args, "--connection") ?? config["DatabaseSettings:Databases:0:ConnectionString"] 
                ?? "Server=127.0.0.1;Port=3306;Uid=root;Pwd=mysql;";

            bool isSqlServer = provider.Equals("SqlServer", StringComparison.OrdinalIgnoreCase) || provider.Equals("MSSQL", StringComparison.OrdinalIgnoreCase);
            bool includeDummy = args.Contains("--dummy") || args.Contains("-d");

            Console.WriteLine($"\n[Target Provider]  : {(isSqlServer ? "MS SQL Server" : "MySQL")}");
            Console.WriteLine($"[Connection String]: {MaskConnectionString(connStr)}");
            Console.WriteLine($"[Include Dummy Data]: {includeDummy}\n");

            try
            {
                // 3. Auto-Create Database if missing
                string dbName = ExtractDatabaseName(connStr, isSqlServer);
                if (!string.IsNullOrEmpty(dbName))
                {
                    Console.WriteLine($"1. Checking Database status for '{dbName}'...");
                    await EnsureDatabaseCreatedAsync(connStr, dbName, isSqlServer);
                }

                // 4. Determine Script Root Folder
                string baseDir = Directory.GetCurrentDirectory();
                string scriptFolderPath = isSqlServer
                    ? Path.Combine(baseDir, "../DNAQMSAPI/DatabaseScripts/MSSQLScript")
                    : Path.Combine(baseDir, "../DNAQMSAPI/DatabaseScripts/MySqlScript");

                if (!Directory.Exists(scriptFolderPath))
                {
                    // Fallback to relative execution path check
                    scriptFolderPath = isSqlServer
                        ? Path.Combine(baseDir, "DatabaseScripts/MSSQLScript")
                        : Path.Combine(baseDir, "DatabaseScripts/MySqlScript");
                }

                if (!Directory.Exists(scriptFolderPath))
                {
                    Console.WriteLine($"❌ ERROR: Script directory not found at path: {Path.GetFullPath(scriptFolderPath)}");
                    return 1;
                }

                Console.WriteLine($"\n2. Executing Migration Scripts from: {Path.GetFileName(scriptFolderPath)}");

                // 5. Gather and Sort SQL Files
                var scriptFiles = Directory.GetFiles(scriptFolderPath, "*.sql", SearchOption.AllDirectories)
                    .Where(f => includeDummy || !f.Contains("DummyData", StringComparison.OrdinalIgnoreCase))
                    .OrderBy(f => Path.GetFileName(f))
                    .ToList();

                Console.WriteLine($"Found {scriptFiles.Count} SQL Migration file(s) to process.\n");

                int successCount = 0;
                foreach (var file in scriptFiles)
                {
                    string fileName = Path.GetFileName(file);
                    Console.Write($" -> Executing [{fileName}]... ");

                    try
                    {
                        string sqlContent = await File.ReadAllTextAsync(file);
                        if (string.IsNullOrWhiteSpace(sqlContent))
                        {
                            Console.WriteLine("SKIP (Empty)");
                            continue;
                        }

                        if (isSqlServer)
                        {
                            await ExecuteSqlServerScriptAsync(connStr, sqlContent);
                        }
                        else
                        {
                            await ExecuteMySqlScriptAsync(connStr, sqlContent);
                        }

                        Console.WriteLine("SUCCESS ✅");
                        successCount++;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"FAILED ❌\n    Details: {ex.Message}");
                    }
                }

                Console.WriteLine("\n==================================================================");
                Console.WriteLine($"  MIGRATION COMPLETE: {successCount}/{scriptFiles.Count} scripts executed successfully.");
                Console.WriteLine("==================================================================");
                return 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n❌ FATAL MIGRATION ERROR: {ex.Message}");
                return 1;
            }
        }

        private static async Task EnsureDatabaseCreatedAsync(string connectionString, string dbName, bool isSqlServer)
        {
            if (isSqlServer)
            {
                var builder = new SqlConnectionStringBuilder(connectionString);
                builder.InitialCatalog = "master";
                using var masterConn = new SqlConnection(builder.ConnectionString);
                await masterConn.OpenAsync();

                using var checkCmd = masterConn.CreateCommand();
                checkCmd.CommandText = $"SELECT database_id FROM sys.databases WHERE name = '{dbName}'";
                var result = await checkCmd.ExecuteScalarAsync();

                if (result == null)
                {
                    Console.WriteLine($" -> Database '{dbName}' does not exist. Creating database...");
                    using var createCmd = masterConn.CreateCommand();
                    createCmd.CommandText = $"CREATE DATABASE [{dbName}];";
                    await createCmd.ExecuteNonQueryAsync();
                    Console.WriteLine($" -> Database '{dbName}' created successfully ✅");
                }
                else
                {
                    Console.WriteLine($" -> Database '{dbName}' already exists ✅");
                }
            }
            else
            {
                var builder = new MySqlConnectionStringBuilder(connectionString);
                builder.Database = "";
                using var rootConn = new MySqlConnection(builder.ConnectionString);
                await rootConn.OpenAsync();

                using var checkCmd = rootConn.CreateCommand();
                checkCmd.CommandText = $"CREATE DATABASE IF NOT EXISTS `{dbName}`;";
                await checkCmd.ExecuteNonQueryAsync();
                Console.WriteLine($" -> Database '{dbName}' verified/created successfully ✅");
            }
        }

        private static async Task ExecuteSqlServerScriptAsync(string connectionString, string scriptContent)
        {
            using var conn = new SqlConnection(connectionString);
            await conn.OpenAsync();

            // Split by GO batches for T-SQL
            var batches = Regex.Split(scriptContent, @"^\s*GO\s*$", RegexOptions.IgnoreCase | RegexOptions.Multiline);

            foreach (var batch in batches)
            {
                if (string.IsNullOrWhiteSpace(batch)) continue;
                using var cmd = conn.CreateCommand();
                cmd.CommandText = batch;
                cmd.CommandTimeout = 300; // Allow 5 minutes for large seeds (e.g. World Location data)
                await cmd.ExecuteNonQueryAsync();
            }
        }

        private static async Task ExecuteMySqlScriptAsync(string connectionString, string scriptContent)
        {
            var builder = new MySqlConnectionStringBuilder(connectionString)
            {
                AllowUserVariables = true
            };

            using var conn = new MySqlConnection(builder.ConnectionString);
            await conn.OpenAsync();

            using var cmd = conn.CreateCommand();
            cmd.CommandText = scriptContent;
            cmd.CommandTimeout = 300;
            await cmd.ExecuteNonQueryAsync();
        }

        private static string ExtractDatabaseName(string connectionString, bool isSqlServer)
        {
            try
            {
                if (isSqlServer)
                {
                    var builder = new SqlConnectionStringBuilder(connectionString);
                    return builder.InitialCatalog;
                }
                else
                {
                    var builder = new MySqlConnectionStringBuilder(connectionString);
                    return builder.Database;
                }
            }
            catch
            {
                return string.Empty;
            }
        }

        private static string GetArgValue(string[] args, string name)
        {
            for (int i = 0; i < args.Length - 1; i++)
            {
                if (args[i].Equals(name, StringComparison.OrdinalIgnoreCase))
                {
                    return args[i + 1];
                }
            }
            return null;
        }

        private static string MaskConnectionString(string connectionString)
        {
            return Regex.Replace(connectionString, @"(?i)(pwd|password)=[^;]+", "$1=******");
        }
    }
}
