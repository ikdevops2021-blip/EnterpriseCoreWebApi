namespace AntiGravity.Enterprise.Shared.Core.Models;

public class PaginatedApiResponse<T> : ApiResponse<IEnumerable<T>>
{
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalRecords { get; set; }
    public int TotalPages => (int)Math.Ceiling(TotalRecords / (double)PageSize);

    public static PaginatedApiResponse<T> Ok(IEnumerable<T> data, int pageNumber, int pageSize, int totalRecords, string message = "Success") =>
        new PaginatedApiResponse<T>
        {
            Success = true,
            Data = data,
            PageNumber = pageNumber,
            PageSize = pageSize,
            TotalRecords = totalRecords,
            Message = message
        };
}
