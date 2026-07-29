namespace DNAQMSAPI.Infrastructure.Models;

public class SPResult
{
    public object ID { get; set; } = 0;
    public int ErrNo { get; set; }
    public int RowsCount { get; set; }
    public string ErrMsg { get; set; } = string.Empty;
    public int ErrLine { get; set; }
}
