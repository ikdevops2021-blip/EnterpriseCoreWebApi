using System;
using System.Collections.Generic;
using System.Linq;

namespace AntiGravity.Enterprise.Shared.Core.Models;

public class RequestContext
{
    public int UserId { get; set; }
    public int CurrentOrganizationId { get; set; }
    public int CurrentCenterId { get; set; }
    public IEnumerable<string> Roles { get; set; } = Array.Empty<string>();
    public IEnumerable<string> Permissions { get; set; } = Array.Empty<string>();
    public string IpAddress { get; set; } = string.Empty;
    public string UserAgent { get; set; } = string.Empty;
    
    // Evaluates if user has specific permission in the current context
    public bool HasPermission(string permission) => Permissions.Contains(permission);
}
