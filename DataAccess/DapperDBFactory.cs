using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;
using MySql.Data.MySqlClient;
using Oracle.ManagedDataAccess.Client;
using Microsoft.Data.Sqlite;
using MongoDB.Driver;
using System.Data.Common;
using System.Security.Authentication;
using Microsoft.Extensions.Options;

namespace DNA.Shared.DataAccess
{
    #region "----------[Database Type----------"
    public enum DatabaseType
    {
        SqlServer,
        MySql,
        Oracle,
        SQLite,
        MongoDb,
        DocumentDb  // Uses MongoDB driver for AWS DocumentDB
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
        public string ConnectionString { get; set; } = string.Empty; // e.g., "SqlServer", "MySQL", "Oracle", "SQLite", "MongoDb"
        public string DatabaseName { get; set; } = string.Empty; // For MongoDb specifically
        public int? Timeout { get; set; } = 30; // Connection timeout in seconds
        public bool UseSSL { get; set; } = false;
    }
    #endregion

    #region "----------[DapperDBFactory Helper]----------"
    public class DapperDBFactory: IDapperDBFactory, IDisposable
    {
        private readonly DatabaseSettings _databaseSettings;
        private IDbConnection _connection;
        private IDbTransaction _transaction;
        private bool _disposed = false;

        //private readonly DatabaseSettings _databaseSettings;
        //private IDbConnection? _connection;
        //private IDbTransaction? _transaction;
        //private bool _disposed = false;

        //public DapperDBFactory(DatabaseSettings databaseSettings)
        //{
        //    _databaseSettings = databaseSettings;
        //}

        public DapperDBFactory(IOptions<DatabaseSettings> databaseSettings)
        {
            _databaseSettings = databaseSettings.Value;

            // Validate settings
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
                System.Diagnostics.Debug.WriteLine("DefaultConnectionName not specified, using first database: {DefaultConnection}", _databaseSettings.DefaultConnectionName);
            }

            if (!_databaseSettings.Databases.Any(db => db.Name == _databaseSettings.DefaultConnectionName))
            {
                throw new InvalidOperationException($"Default connection '{_databaseSettings.DefaultConnectionName}' not found in database configurations");
            }
        }

        // Helper method to get the database connection
        //public IDbConnection GetConnection(string ConnectionName= "DefaultConnection")
        //{
        //    var databaseConfig = _databaseSettings.Databases.FirstOrDefault(db => db.Name == ConnectionName);
        //    if (databaseConfig == null)
        //    {
        //        throw new ArgumentException($"Database configuration for '{ConnectionName}' not found.");
        //    }

        //    // Build final connection string if necessary, though the provided one handles it for some types.
        //    // For simplicity, we'll use databaseConfig.ConnectionString directly for ADO.NET providers.
        //    // You might want to integrate BuildFinalConnectionString more consistently if all connections use it.

        //    switch (databaseConfig.Type)
        //    {
        //        case "SqlServer":
        //            return new SqlConnection(databaseConfig.ConnectionString);
        //        case "MySQL":
        //            return new MySqlConnection(databaseConfig.ConnectionString);
        //        case "Oracle":
        //            return new OracleConnection(databaseConfig.ConnectionString);
        //        case "SQLite":
        //            return new SqliteConnection(databaseConfig.ConnectionString);
        //        case "MongoDb":
        //            // For MongoDB, you typically work with IMongoDatabase, not IDbConnection.
        //            // This will require a slight adjustment to how MongoDB is handled if you truly
        //            // want it to fit the IDbConnection interface, which is not ideal for NoSQL.
        //            // For now, we'll return a mock or throw, or adapt it.
        //            // A better approach for MongoDb would be a separate factory or a different interface method.
        //            // For this example, let's make it work for the IDbConnection pattern as much as possible for demonstration,
        //            // but note that direct Dapper usage with MongoDb is unconventional as Dapper is for relational DBs.
        //            // If you intend to use MongoDb with Dapper, you'd typically use a driver that mimics ADO.NET, or a custom Dapper extension.
        //            // For a true MongoDb connection, you'd usually do:
        //            var client = new MongoClient(databaseConfig.ConnectionString);
        //            return new MongoDbConnectionWrapper(client.GetDatabase(databaseConfig.DatabaseName)); // Custom wrapper needed
        //            //return (IDbConnection)client.GetDatabase(databaseConfig.DatabaseName);
        //        default:
        //            throw new NotSupportedException($"Database type '{databaseConfig.Type}' is not supported.");
        //    }
        //}


        // Helper method to get the database connection
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
                // Build final connection string if necessary, though the provided one handles it for some types.
                // For simplicity, we'll use databaseConfig.ConnectionString directly for ADO.NET providers.
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
                //_logger.LogError(ex, "Error creating connection for {ConnectionName}", connectionToUse);
                System.Diagnostics.Debug.WriteLine($"Error creating connection for {connectionToUse} ^ Error: {ex.Message.ToString()}");
                throw;
            }
        }
        //private string BuildFinalConnectionString(DatabaseConfig _config)
        //{
        //    // Note: This method is not fully integrated into the GetConnection switch yet.
        //    // For robust connection string building, you'd want to use DbConnectionStringBuilder for all types.
        //    // This method currently expects a full connection string and adds common options.
        //    // For a production system, consider a more sophisticated connection string builder for each DB type.
        //    var builder = new DbConnectionStringBuilder
        //    {
        //        ConnectionString = _config.ConnectionString
        //    };

        //    // Add common options (these might be SQL Server specific)
        //    // Ensure these keys are valid for the specific database type.
        //    builder["Connect Timeout"] = _config.Timeout;

        //    if (_config.UseSSL)
        //    {
        //        // These are primarily for SQL Server and similar, may not apply universally.
        //        builder["Encrypt"] = true;
        //        builder["TrustServerCertificate"] = false;
        //    }

        //    return builder.ToString();
        //}

        private string BuildFinalConnectionString(DatabaseConfig config)
        {
            // Note: This method is not fully integrated into the GetConnection switch yet.
            // For robust connection string building, you'd want to use DbConnectionStringBuilder for all types.
            // This method currently expects a full connection string and adds common options.
            // For a production system, consider a more sophisticated connection string builder for each DB type.

            if (config.Type.Equals("MongoDb", StringComparison.OrdinalIgnoreCase))
            {
                return config.ConnectionString; // MongoDB connection string is handled differently
            }

            var builder = new DbConnectionStringBuilder
            {
                ConnectionString = config.ConnectionString
            };

            // Add common options (these might be SQL Server specific)
            // Ensure these keys are valid for the specific database type.
            if (config.Timeout.HasValue)
            {
                builder["Connect Timeout"] = config.Timeout.Value;
            }

            if (config.UseSSL)
            {
                // SSL settings for supported databases
                // These are primarily for SQL Server and similar, may not apply universally.
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

        // Create MongoDB connection
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

        // Begin a transaction
        //public void BeginTransaction(string databaseName)
        //{
        //    if (_connection != null && _connection.State == ConnectionState.Open)
        //    {
        //        throw new InvalidOperationException("A connection is already open. Please close it or ensure proper transaction management.");
        //    }

        //    _connection = GetConnection(databaseName);
        //    _connection.Open();
        //    _transaction = _connection.BeginTransaction();
        //}

        public void BeginTransaction(string? databaseName = null)
        {
            if (_connection != null && _connection.State == ConnectionState.Open)
            {
                throw new InvalidOperationException("A connection is already open. Please close it or ensure proper transaction management.");
            }

            _connection = GetConnection(databaseName);
            _connection.Open();
            _transaction = _connection.BeginTransaction();

            System.Diagnostics.Debug.WriteLine("Transaction started for database: {DatabaseName}", databaseName ?? _databaseSettings.DefaultConnectionName);
        }

        // Commit the transaction
        //public void CommitTransaction()
        //{
        //    _transaction?.Commit();
        //    _connection?.Close();
        //    _transaction = null; // Clear transaction and connection after commit/rollback
        //    _connection = null;
        //}

        public void CommitTransaction()
        {
            if (_transaction == null)
            {
                throw new InvalidOperationException("No active transaction to commit");
            }

            _transaction.Commit();
            _connection?.Close();
            _transaction = null;
            _connection = null;

            System.Diagnostics.Debug.WriteLine("Transaction committed successfully");
        }

        // Rollback the transaction
        //public void RollbackTransaction()
        //{
        //    _transaction?.Rollback();
        //    _connection?.Close();
        //    _transaction = null; // Clear transaction and connection after commit/rollback
        //    _connection = null;
        //}

        public void RollbackTransaction()
        {
            if (_transaction == null)
            {
                throw new InvalidOperationException("No active transaction to rollback");
            }

            _transaction.Rollback();
            _connection?.Close();
            _transaction = null;
            _connection = null;

            System.Diagnostics.Debug.WriteLine("Transaction rolled back");
        }

        // Execute a query and return a single result
        //public async Task<T?> QuerySingleAsync<T>(string connectionName, string sql, object? parameters = null, CommandType commandType = CommandType.Text)
        //{
        //    // Use the _connection and _transaction if a transaction is active, otherwise create a new connection.
        //    if (_transaction != null && _connection != null)
        //    {
        //        return await _connection.QuerySingleOrDefaultAsync<T>(sql, parameters, transaction: _transaction, commandType: commandType);
        //    }
        //    else
        //    {
        //        using (var connection = GetConnection(connectionName))
        //        {
        //            return await connection.QuerySingleOrDefaultAsync<T>(sql, parameters, commandType: commandType);
        //        }
        //    }

        //    //using (var connection = GetConnection(connectionName))
        //    //{
        //    //    return await connection.QuerySingleOrDefaultAsync<T>(sql, parameters, commandType: commandType);
        //    //}
        //}

        public async Task<T?> QuerySingleAsync<T>(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text)
        {
            if (_transaction != null && _connection != null)
            {
                return await _connection.QuerySingleOrDefaultAsync<T>(sql, parameters, transaction: _transaction, commandType: commandType);
            }
            else
            {
                using (var connection = GetConnection(connectionName))
                {
                    return await connection.QuerySingleOrDefaultAsync<T>(sql, parameters, commandType: commandType);
                }
            }
        }

        // Execute a query and return a list of results
        //public async Task<IEnumerable<T?>> QueryAsync<T>(string connectionName, string sql, object? parameters = null, CommandType commandType = CommandType.Text)
        //{
        //    //using (var connection = GetConnection(connectionName))
        //    //{
        //    //    return await connection.QueryAsync<T>(sql, parameters, commandType: commandType);
        //    //}

        //    if (_transaction != null && _connection != null)
        //    {
        //        return await _connection.QueryAsync<T>(sql, parameters, transaction: _transaction, commandType: commandType);
        //    }
        //    else
        //    {
        //        using (var connection = GetConnection(connectionName))
        //        {
        //            return await connection.QueryAsync<T>(sql, parameters, commandType: commandType);
        //        }
        //    }
        //}

        public async Task<IEnumerable<T?>> QueryAsync<T>(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text)
        {
            if (_transaction != null && _connection != null)
            {
                return await _connection.QueryAsync<T>(sql, parameters, transaction: _transaction, commandType: commandType);
            }
            else
            {
                using (var connection = GetConnection(connectionName))
                {
                    return await connection.QueryAsync<T>(sql, parameters, commandType: commandType);
                }
            }
        }

        //public async Task<IEnumerable<dynamic>> QueryStoredProcedureAsync(string connectionName, string procedureName, object parameters = null)
        //{
        //    using (var connection = GetConnection(connectionName)) 
        //    {
        //        return await connection.QueryAsync(procedureName, parameters, commandType: CommandType.StoredProcedure);
        //    }
            
        //}

        public async Task<IEnumerable<dynamic>> QueryStoredProcedureAsync(string procedureName, object? parameters = null, string? connectionName = null)
        {
            using (var connection = GetConnection(connectionName))
            {
                return await connection.QueryAsync(procedureName, parameters, commandType: CommandType.StoredProcedure);
            }
        }

        #region "---------------------[CALL SP AND RETURN MULTIPLE RESULTSETS]---------------------"
        // Execute a stored procedure and return multiple result sets
        //public async Task<SqlMapper.GridReader> QueryMultipleAsync(string connectionName, string storedProcedure, object? parameters = null)
        //{
        //    //using (var connection = GetConnection(connectionName))
        //    //{
        //    //    return await connection.QueryMultipleAsync(
        //    //        storedProcedure,
        //    //        parameters,
        //    //        commandType: CommandType.StoredProcedure
        //    //    );
        //    //}

        //    // Note: QueryMultipleAsync with Dapper's GridReader is designed for a single connection scope.
        //    // If you are using transactions, you would pass the transaction and connection to this.
        //    // If not, it will open and close its own connection.
        //    // For transaction-aware use, you'd modify this to accept _connection and _transaction directly.
        //    // As currently written, if a transaction is active, this will open a *new* connection,
        //    // which is not desired for transactional consistency.
        //    // Let's modify this to use the active transaction if available.

        //    if (_transaction != null && _connection != null)
        //    {
        //        return await _connection.QueryMultipleAsync(
        //            storedProcedure,
        //            parameters,
        //            commandType: CommandType.StoredProcedure,
        //            transaction: _transaction
        //        );
        //    }
        //    else
        //    {
        //        var connection = GetConnection(connectionName); // Don't use 'using' here as GridReader needs connection to stay open
        //        // The caller of QueryMultipleAsync is responsible for disposing the GridReader,
        //        // which will in turn close the connection if it was created internally.
        //        try
        //        {
        //            return await connection.QueryMultipleAsync(
        //                storedProcedure,
        //                parameters,
        //                commandType: CommandType.StoredProcedure
        //            );
        //        }
        //        catch
        //        {
        //            connection.Dispose(); // Ensure connection is disposed on error
        //            throw;
        //        }
        //    }
        //}

        public async Task<SqlMapper.GridReader> QueryMultipleAsync(string storedProcedure, object? parameters = null, string? connectionName = null)
        {
            // Note: QueryMultipleAsync with Dapper's GridReader is designed for a single connection scope.
            // If you are using transactions, you would pass the transaction and connection to this.
            // If not, it will open and close its own connection.
            // For transaction-aware use, you'd modify this to accept _connection and _transaction directly.
            // As currently written, if a transaction is active, this will open a *new* connection,
            // which is not desired for transactional consistency.
            // Let's modify this to use the active transaction if available.

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
                var connection = GetConnection(connectionName); // Don't use 'using' here as GridReader needs connection to stay open
                // The caller of QueryMultipleAsync is responsible for disposing the GridReader,
                // which will in turn close the connection if it was created internally.
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
                    throw;
                }
                finally {
                    connection.Dispose(); // Ensure connection is disposed on error
                }
            }
        }

        // Execute a stored procedure and return multiple result sets Method - 2
        //public async Task<IEnumerable<IEnumerable<dynamic?>>> QueryMultipleStoredProcedureAsync(string connectionName, string procedureName, object parameters = null, IDbTransaction transaction = null)
        //{
        //    //using var connection = GetConnection(connectionName);
        //    //using var multi = await connection.QueryMultipleAsync(procedureName, parameters, commandType: CommandType.StoredProcedure, transaction: transaction);
        //    //var results = new List<IEnumerable<dynamic>>();
        //    //while (!multi.IsConsumed)
        //    //{
        //    //    results.Add(await multi.ReadAsync());
        //    //}
        //    //return results;

        //    // This method already accepts a transaction, so we can prioritize it.
        //    // If a factory transaction is active, use it. Otherwise, use the passed transaction or a new connection.
        //    IDbConnection connection;
        //    IDbTransaction? currentTransaction = null;

        //    if (_transaction != null && _connection != null)
        //    {
        //        connection = _connection;
        //        currentTransaction = _transaction;
        //    }
        //    else if (transaction != null)
        //    {
        //        connection = transaction.Connection ?? throw new ArgumentException("Transaction must have an associated connection.");
        //        currentTransaction = transaction;
        //    }
        //    else
        //    {
        //        connection = GetConnection(connectionName);
        //        connection.Open(); // Open the connection for this scope
        //    }

        //    try
        //    {
        //        using var multi = await connection.QueryMultipleAsync(procedureName, parameters, commandType: CommandType.StoredProcedure, transaction: currentTransaction);
        //        var results = new List<IEnumerable<dynamic>>();
        //        while (!multi.IsConsumed)
        //        {
        //            results.Add(await multi.ReadAsync());
        //        }
        //        return results;
        //    }
        //    finally
        //    {
        //        if (currentTransaction == null && connection.State == ConnectionState.Open) // Only close if we opened it and no external transaction
        //        {
        //            connection.Close();
        //            connection.Dispose();
        //        }
        //    }
        //}

        public async Task<IEnumerable<IEnumerable<dynamic?>>> QueryMultipleStoredProcedureAsync(string procedureName, object? parameters = null, IDbTransaction? transaction = null, string? connectionName = null)
        {
            // This method already accepts a transaction, so we can prioritize it.
            // If a factory transaction is active, use it. Otherwise, use the passed transaction or a new connection.
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
                connection.Open(); // Open the connection for this scope
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

        //---EXAMPLE USING Multiple Result Return
        //[HttpGet("multiple-results")]
        //public async Task<IActionResult> GetMultipleResults([FromQuery] string connectionName = "MsSql")
        //{
        //    // Example Stored Procedure:
        //    //
        //    // CREATE PROCEDURE GetProductsAndCategories
        //    // AS
        //    // BEGIN
        //    //     SELECT Id, Name, Description, Price FROM Products;
        //    //     SELECT Id, CategoryName FROM Categories;
        //    // END
        //    //
        //    // In this example, the stored procedure returns two result sets:
        //    // 1. A list of products (Id, Name, Description, Price)
        //    // 2. A list of categories (Id, CategoryName)

        //    var results = await _productService.GetProductsAndCategories(connectionName);

        //    // Results[0] will contain the products
        //    // Results[1] will contain the categories

        //    return Ok(new
        //    {
        //        Products = results[0],
        //        Categories = results[1]
        //    });
        //}
        #endregion

        // Execute a command (e.g., INSERT, UPDATE, DELETE)
        //public async Task<int> ExecuteAsync(string connectionName, string sql, object? parameters = null, CommandType commandType = CommandType.Text)
        //{
        //    //using (var connection = GetConnection(connectionName))
        //    //{
        //    //    return await connection.ExecuteAsync(sql, parameters, commandType: commandType);
        //    //}

        //    if (_transaction != null && _connection != null)
        //    {
        //        return await _connection.ExecuteAsync(sql, parameters, transaction: _transaction, commandType: commandType);
        //    }
        //    else
        //    {
        //        using (var connection = GetConnection(connectionName))
        //        {
        //            return await connection.ExecuteAsync(sql, parameters, commandType: commandType);
        //        }
        //    }
        //}

        public async Task<int> ExecuteAsync(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text)
        {
            if (_transaction != null && _connection != null)
            {
                return await _connection.ExecuteAsync(sql, parameters, transaction: _transaction, commandType: commandType);
            }
            else
            {
                using (var connection = GetConnection(connectionName))
                {
                    return await connection.ExecuteAsync(sql, parameters, commandType: commandType);
                }
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

        #region IDisposable Implementation
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
                            try
                            {
                                _connection.Close();
                            }
                            catch
                            {
                                // Suppress errors during disposal
                            }
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
        #endregion
    }
    #endregion

    #region "----------[MongoHelper Helper - Method 1]----------"
    public class MongoHelper
    {
        private readonly DatabaseConfig _config;
        private readonly IMongoDatabase _database;

        public MongoHelper(DatabaseConfig config)
        {
            _config = config ?? throw new ArgumentNullException(nameof(config));
            ValidateMongoConfig();

            var settings = MongoClientSettings.FromUrl(new MongoUrl(config.ConnectionString));
            settings.SslSettings = new SslSettings
            {
                EnabledSslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13,
                CheckCertificateRevocation = config.UseSSL
            };

            var client = new MongoClient(settings);
            _database = client.GetDatabase(config.DatabaseName);
        }

        private void ValidateMongoConfig()
        {
            if (string.IsNullOrWhiteSpace(_config.DatabaseName))
                throw new ArgumentException("Database name is required for MongoDB");
        }

        public IMongoCollection<T> GetCollection<T>(string collectionName)
        {
            return _database.GetCollection<T>(collectionName);
        }

        public async Task InsertDocument<T>(string collectionName, T document)
        {
            var collection = GetCollection<T>(collectionName);
            await collection.InsertOneAsync(document);
        }

        public async Task<List<T>> GetDocuments<T>(string collectionName, FilterDefinition<T> filter = null)
        {
            var collection = GetCollection<T>(collectionName);
            return await collection.Find(filter ?? Builders<T>.Filter.Empty).ToListAsync();
        }

        public async Task UpdateDocument<T>(string collectionName, FilterDefinition<T> filter, UpdateDefinition<T> update)
        {
            var collection = GetCollection<T>(collectionName);
            await collection.UpdateOneAsync(filter, update);
        }

        public async Task DeleteDocument<T>(string collectionName, FilterDefinition<T> filter)
        {
            var collection = GetCollection<T>(collectionName);
            await collection.DeleteOneAsync(filter);
        }
    }
    #endregion

    #region "----------[MongoDB Helper - Method 2]------------"
    // --- IMPORTANT NOTE FOR MongoDB ---
    // Dapper is designed for relational databases (SQL, MySQL, etc.) which implement IDbConnection.
    // MongoDB's official driver does *not* implement IDbConnection.
    // To make `GetConnection` return an IDbConnection for MongoDB, you'd need a custom wrapper.
    // Below is a *very basic* example of such a wrapper. In a real-world scenario, you'd use the official MongoDB driver
    // directly and *not* try to force it into the Dapper/IDbConnection pattern unless there's a specialized Dapper extension for MongoDB.
    // For the purpose of this example, I will include a placeholder wrapper.
    public class MongoDbConnectionWrapper : IDbConnection
    {
        private readonly IMongoDatabase _database;

        public MongoDbConnectionWrapper(IMongoDatabase database)
        {
            _database = database;
        }

        // Implement IDbConnection members. Most of these will be no-ops or throw NotSupportedExceptions
        // as MongoDB doesn't work with transactions, commands, or standard SQL queries in the same way.
        public string ConnectionString { get; set; } = string.Empty;
        public int ConnectionTimeout => 0; // Not applicable
        public string Database => _database.DatabaseNamespace.DatabaseName;
        public ConnectionState State => ConnectionState.Open; // Assume always open for basic operations

        public IDbTransaction BeginTransaction() => throw new NotSupportedException("MongoDB does not support standard IDbTransaction.");
        public IDbTransaction BeginTransaction(IsolationLevel il) => throw new NotSupportedException("MongoDB does not support standard IDbTransaction.");
        public void ChangeDatabase(string databaseName) => throw new NotSupportedException("Changing database not supported via this wrapper.");
        public void Close() { /* No-op */ }
        public IDbCommand CreateCommand() => throw new NotSupportedException("MongoDB does not support standard IDbCommand.");
        public void Open() { /* No-op */ }
        public void Dispose() { /* No-op */ }

        // This is the key part: exposing the underlying MongoDB database for direct use if needed
        public IMongoDatabase GetMongoDatabase() => _database;
    }
    // --- END MongoDB NOTE ---
    #endregion

    #region "----------[DapperDBFactory Helper appsettings.json]----------"
    /*
     "DatabaseSettings": {
    "DefaultConnectionName": "DefaultConnection"
    "Databases": [
      {
        "Name": "MainSQLServer",
        "Type": "SqlServer",
        "ConnectionString": "Server=myServer;Database=myDB;User Id=myUser;Password=myPass;",
        "Timeout": 45,
        "UseSSL": true
      },
      {
        "Name": "AnalyticsMongoDB",
        "Type": "MongoDb",
        "ConnectionString": "mongodb://user:pass@localhost:27017",
        "DatabaseName": "analytics",
        "UseSSL": false
      },
      {
        "Name": "LoggingSQLite",
        "Type": "SQLite",
        "ConnectionString": "Data Source=./logs.db",
        "Timeout": 60
      }
    ]
  },

    Registration
    public void ConfigureServices(IServiceCollection services)
    {
        // Bind DatabaseSettings from appsettings.json
        services.Configure<DatabaseSettings>(Configuration.GetSection("DatabaseSettings"));

        // Register DapperHelper with DatabaseSettings
        services.AddSingleton<DapperHelper>(sp =>
        {
            var databaseSettings = sp.GetRequiredService<IOptions<DatabaseSettings>>().Value;
            return new DapperHelper(databaseSettings);
        });

        // Other service registrations
    }
    */
    #endregion

    #region "----------[USE Dapper DBFactory EXAMPLE]----------"
    //// In Program.cs - Add these services
    //builder.Services.Configure<DatabaseSettings>(builder.Configuration.GetSection("DatabaseSettings"));
    //builder.Services.AddSingleton<IDapperDBFactory, DapperDBFactory>();

    //// Example 1: Using default connection
    //public class UserRepository
    //{
    //    private readonly IDapperDBFactory _dbFactory;

    //    public UserRepository(IDapperDBFactory dbFactory)
    //    {
    //        _dbFactory = dbFactory;
    //    }

    //    public async Task<User> GetUserById(int userId)
    //    {
    //        var sql = "SELECT * FROM Users WHERE Id = @UserId";
    //        return await _dbFactory.QuerySingleAsync<User>(sql, new { UserId = userId });
    //    }
    //}

    //// Example 2: Using specific connection
    //public async Task<List<Log>> GetLogs()
    //{
    //    var sql = "SELECT * FROM Logs ORDER BY Timestamp DESC";
    //    return (await _dbFactory.QueryAsync<Log>(sql, connectionName: "LoggingSQLite")).ToList();
    //}

    //// Example 3: Transaction usage
    //public async Task TransferFunds(int fromAccount, int toAccount, decimal amount)
    //{
    //    _dbFactory.BeginTransaction(); // Uses default connection

    //    try
    //    {
    //        // Deduct from source account
    //        await _dbFactory.ExecuteAsync(
    //            "UPDATE Accounts SET Balance = Balance - @Amount WHERE Id = @AccountId",
    //            new { Amount = amount, AccountId = fromAccount }
    //        );

    //        // Add to destination account
    //        await _dbFactory.ExecuteAsync(
    //            "UPDATE Accounts SET Balance = Balance + @Amount WHERE Id = @AccountId",
    //            new { Amount = amount, AccountId = toAccount }
    //        );

    //        _dbFactory.CommitTransaction();
    //    }
    //    catch
    //    {
    //        _dbFactory.RollbackTransaction();
    //        throw;
    //    }
    //}

    //// Example 4: Stored procedure with multiple results
    //public async Task<DashboardData> GetDashboardData()
    //{
    //    using var multi = await _dbFactory.QueryMultipleAsync("spGetDashboardData");

    //    return new DashboardData
    //    {
    //        Users = await multi.ReadAsync<User>(),
    //        Stats = await multi.ReadSingleOrDefaultAsync<DashboardStats>(),
    //        RecentActivity = await multi.ReadAsync<Activity>()
    //    };
    //}
    #endregion


}