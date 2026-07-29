using System.Data;
using System.Data.Common;
using System.Security.Authentication;
using Dapper;
using DNAQMSAPI.Application.Interfaces;
using Microsoft.Data.SqlClient;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using MySql.Data.MySqlClient;
using Oracle.ManagedDataAccess.Client;

namespace DNAQMSAPI.Infrastructure.Data;

#region "----------[Database Type----------"
public enum DatabaseType
{
    SqlServer,
    MySql,
    Oracle,
    SQLite,
    MongoDb,
    DocumentDb
}
#endregion

#region "----------[Database Settings]----------"
public class DatabaseSettings
{
    public string DefaultConnectionName { get; set; } = "DefaultConnection";
    public List<DatabaseConfig> Databases { get; set; } = new List<DatabaseConfig>();
}

public class DatabaseConfig
{
    public string Name { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public string ConnectionString { get; set; } = string.Empty;
    public string DatabaseName { get; set; } = string.Empty;
    public int? Timeout { get; set; } = 30;
    public bool UseSSL { get; set; } = false;
}
#endregion

public class DapperDBFactory : IDapperDBFactory, IDisposable
{
    private readonly DatabaseSettings _databaseSettings;
    private IDbConnection? _connection;
    private IDbTransaction? _transaction;
    private bool _disposed = false;

    public DapperDBFactory(IOptions<DatabaseSettings> databaseSettings)
    {
        _databaseSettings = databaseSettings.Value;
        ValidateDatabaseSettings();
    }

    private void ValidateDatabaseSettings()
    {
        if (_databaseSettings.Databases == null || !_databaseSettings.Databases.Any())
        {
            throw new InvalidOperationException("No database configurations found in settings");
        }

        if (string.IsNullOrEmpty(_databaseSettings.DefaultConnectionName))
        {
            _databaseSettings.DefaultConnectionName = _databaseSettings.Databases.First().Name;
        }

        if (!_databaseSettings.Databases.Any(db => db.Name == _databaseSettings.DefaultConnectionName))
        {
            throw new InvalidOperationException($"Default connection '{_databaseSettings.DefaultConnectionName}' not found in database configurations");
        }
    }

    public IDbConnection GetConnection(string? connectionName = null)
    {
        var connectionToUse = connectionName ?? _databaseSettings.DefaultConnectionName;
        var databaseConfig = _databaseSettings.Databases.FirstOrDefault(db => db.Name == connectionToUse);

        if (databaseConfig == null)
        {
            throw new ArgumentException($"Database configuration for '{connectionToUse}' not found. Available connections: {string.Join(", ", GetAvailableConnectionNames())}");
        }

        try
        {
            var finalConnectionString = BuildFinalConnectionString(databaseConfig);

            return databaseConfig.Type.ToLower() switch
            {
                "sqlserver" => new SqlConnection(finalConnectionString),
                "mysql" => new MySqlConnection(finalConnectionString),
                "oracle" => new OracleConnection(finalConnectionString),
                "sqlite" => new SqliteConnection(finalConnectionString),
                "mongodb" => new MongoDbConnectionWrapper(CreateMongoDatabase(databaseConfig)),
                _ => throw new NotSupportedException($"Database type '{databaseConfig.Type}' is not supported.")
            };
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error creating connection for {connectionToUse} ^ Error: {ex.Message}");
            throw;
        }
    }

    private string BuildFinalConnectionString(DatabaseConfig config)
    {
        if (config.Type.Equals("MongoDb", StringComparison.OrdinalIgnoreCase))
        {
            return config.ConnectionString;
        }

        var builder = new DbConnectionStringBuilder
        {
            ConnectionString = config.ConnectionString
        };

        if (config.Timeout.HasValue)
        {
            builder["Connect Timeout"] = config.Timeout.Value;
        }

        if (config.UseSSL)
        {
            if (config.Type.Equals("SqlServer", StringComparison.OrdinalIgnoreCase))
            {
                builder["Encrypt"] = true;
                builder["TrustServerCertificate"] = true;
            }
            else if (config.Type.Equals("MySql", StringComparison.OrdinalIgnoreCase))
            {
                builder["SslMode"] = "Required";
            }
        }

        return builder.ToString();
    }

    private IMongoDatabase CreateMongoDatabase(DatabaseConfig config)
    {
        if (string.IsNullOrEmpty(config.DatabaseName))
        {
            throw new ArgumentException("DatabaseName is required for MongoDB connections");
        }

        var settings = MongoClientSettings.FromUrl(new MongoUrl(config.ConnectionString));

        if (config.UseSSL)
        {
            settings.SslSettings = new SslSettings
            {
                EnabledSslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13,
                CheckCertificateRevocation = false
            };
        }

        var client = new MongoClient(settings);
        return client.GetDatabase(config.DatabaseName);
    }

    public void BeginTransaction(string? databaseName = null)
    {
        if (_connection != null && _connection.State == ConnectionState.Open)
        {
            throw new InvalidOperationException("A connection is already open. Please close it or ensure proper transaction management.");
        }

        _connection = GetConnection(databaseName);
        _connection.Open();
        _transaction = _connection.BeginTransaction();
    }

    public void CommitTransaction()
    {
        if (_transaction == null)
            throw new InvalidOperationException("No active transaction to commit");

        _transaction.Commit();
        _connection?.Close();
        _transaction = null;
        _connection = null;
    }

    public void RollbackTransaction()
    {
        if (_transaction == null)
            throw new InvalidOperationException("No active transaction to rollback");

        _transaction.Rollback();
        _connection?.Close();
        _transaction = null;
        _connection = null;
    }

    public async Task<T?> QuerySingleAsync<T>(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text)
    {
        if (_transaction != null && _connection != null)
        {
            return await _connection.QuerySingleOrDefaultAsync<T>(sql, parameters, transaction: _transaction, commandType: commandType);
        }
        else
        {
            using var connection = GetConnection(connectionName);
            return await connection.QuerySingleOrDefaultAsync<T>(sql, parameters, commandType: commandType);
        }
    }

    public async Task<IEnumerable<T?>> QueryAsync<T>(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text)
    {
        if (_transaction != null && _connection != null)
        {
            return await _connection.QueryAsync<T>(sql, parameters, transaction: _transaction, commandType: commandType);
        }
        else
        {
            using var connection = GetConnection(connectionName);
            return await connection.QueryAsync<T>(sql, parameters, commandType: commandType);
        }
    }

    public async Task<IEnumerable<dynamic>> QueryStoredProcedureAsync(string procedureName, object? parameters = null, string? connectionName = null)
    {
        using var connection = GetConnection(connectionName);
        return await connection.QueryAsync(procedureName, parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<SqlMapper.GridReader> QueryMultipleAsync(string storedProcedure, object? parameters = null, string? connectionName = null)
    {
        if (_transaction != null && _connection != null)
        {
            return await _connection.QueryMultipleAsync(
                storedProcedure,
                parameters,
                commandType: CommandType.StoredProcedure,
                transaction: _transaction
            );
        }
        else
        {
            var connection = GetConnection(connectionName);
            try
            {
                return await connection.QueryMultipleAsync(
                    storedProcedure,
                    parameters,
                    commandType: CommandType.StoredProcedure
                );
            }
            catch
            {
                connection.Dispose();
                throw;
            }
        }
    }

    public async Task<IEnumerable<IEnumerable<dynamic?>>> QueryMultipleStoredProcedureAsync(string procedureName, object? parameters = null, IDbTransaction? transaction = null, string? connectionName = null)
    {
        IDbConnection connection;
        IDbTransaction? currentTransaction = null;

        if (_transaction != null && _connection != null)
        {
            connection = _connection;
            currentTransaction = _transaction;
        }
        else if (transaction != null)
        {
            connection = transaction.Connection ?? throw new ArgumentException("Transaction must have an associated connection.");
            currentTransaction = transaction;
        }
        else
        {
            connection = GetConnection(connectionName);
            connection.Open();
        }

        try
        {
            using var multi = await connection.QueryMultipleAsync(procedureName, parameters, commandType: CommandType.StoredProcedure, transaction: currentTransaction);
            var results = new List<IEnumerable<dynamic>>();
            while (!multi.IsConsumed)
            {
                results.Add(await multi.ReadAsync());
            }
            return results;
        }
        finally
        {
            if (currentTransaction == null && connection.State == ConnectionState.Open)
            {
                connection.Close();
                connection.Dispose();
            }
        }
    }

    public async Task<int> ExecuteAsync(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text)
    {
        if (_transaction != null && _connection != null)
        {
            return await _connection.ExecuteAsync(sql, parameters, transaction: _transaction, commandType: commandType);
        }
        else
        {
            using var connection = GetConnection(connectionName);
            return await connection.ExecuteAsync(sql, parameters, commandType: commandType);
        }
    }

    public string GetDefaultConnectionName()
    {
        return _databaseSettings.DefaultConnectionName;
    }

    public List<string> GetAvailableConnectionNames()
    {
        return _databaseSettings.Databases.Select(db => db.Name).ToList();
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!_disposed)
        {
            if (disposing)
            {
                if (_transaction != null)
                {
                    _transaction.Dispose();
                    _transaction = null;
                }

                if (_connection != null)
                {
                    if (_connection.State != ConnectionState.Closed)
                    {
                        try { _connection.Close(); } catch { }
                    }
                    _connection.Dispose();
                    _connection = null;
                }
            }

            _disposed = true;
        }
    }

    ~DapperDBFactory()
    {
        Dispose(false);
    }
}

// Minimal MongoDbConnectionWrapper to satisfy the compiler because the user implementation leverages this wrap
public class MongoDbConnectionWrapper : IDbConnection
{
    private readonly IMongoDatabase _database;

    public MongoDbConnectionWrapper(IMongoDatabase database)
    {
        _database = database;
    }

    public string ConnectionString { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
    public int ConnectionTimeout => throw new NotImplementedException();
    public string Database => _database.DatabaseNamespace.DatabaseName;
    public ConnectionState State => ConnectionState.Open;

    public IDbTransaction BeginTransaction() => throw new NotSupportedException();
    public IDbTransaction BeginTransaction(IsolationLevel il) => throw new NotSupportedException();
    public void ChangeDatabase(string databaseName) => throw new NotSupportedException();
    public void Close() { }
    public IDbCommand CreateCommand() => throw new NotSupportedException();
    public void Dispose() { }
    public void Open() { }
}
