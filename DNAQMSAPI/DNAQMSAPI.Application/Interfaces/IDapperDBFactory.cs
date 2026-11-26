using System.Data;
using Dapper;

namespace DNAQMSAPI.Application.Interfaces;

public interface IDapperDBFactory
{
    IDbConnection GetConnection(string? connectionName = null);
    IDbConnection GetConnectionForRegion(string dataRegion);
    IDbConnection GetConnectionForOrganization(int organizationId);
    void RegisterOrganizationRegion(int organizationId, string dataRegion);
    string? ResolveRegionForOrganization(int organizationId);
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
