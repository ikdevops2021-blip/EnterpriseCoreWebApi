using System.Collections.Generic;

namespace DNAQMSAPI.Application.DTOs;

public class LoginResponseDto
{
    public string Token { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string UserCode { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string RoleName { get; set; } = string.Empty;
    public int OrganizationId { get; set; } = 1;
    public List<int> AssignedProcessIds { get; set; } = new();
    public List<int> AssignedCounterIds { get; set; } = new();
}
