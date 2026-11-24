using System;
using System.Threading.Tasks;

namespace DNAQMSAPI.Application.Interfaces;

public class WebhookEventMessage
{
    public string EventCode { get; set; } = string.Empty;
    public int OrganizationId { get; set; }
    public int? LocationId { get; set; }
    public object? Data { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

public interface IWebhookDispatcher
{
    ValueTask EnqueueEventAsync(string eventCode, int organizationId, int? locationId, object data);
}
