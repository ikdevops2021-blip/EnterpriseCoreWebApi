using System.Data;
using Dapper;

namespace AntiGravity.Enterprise.Shared.Core.Data;

public interface IDapperDBFactory
{
    IDbConnection GetConnection(string? connectionName = null);
    void BeginTransaction(string? databaseName = null);
    void CommitTransaction();
    void RollbackTransaction();
    Task<T?> QuerySingleAsync<T>(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text);
    Task<IEnumerable<T?>> QueryAsync<T>(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text);
    Task<IEnumerable<dynamic>> QueryStoredProcedureAsync(string procedureName, object? parameters = null, string? connectionName = null);
    Task<SqlMapper.GridReader> QueryMultipleAsync(string storedProcedure, object? parameters = null, string? connectionName = null);
    Task<IEnumerable<IEnumerable<dynamic?>>> QueryMultipleStoredProcedureAsync(string procedureName, object? parameters = null, IDbTransaction? transaction = null, string? connectionName = null);
    Task<int> ExecuteAsync(string sql, object? parameters = null, string? connectionName = null, CommandType commandType = CommandType.Text);
    string GetDefaultConnectionName();
    List<string> GetAvailableConnectionNames();
}
