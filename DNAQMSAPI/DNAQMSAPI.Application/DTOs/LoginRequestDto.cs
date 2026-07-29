namespace DNAQMSAPI.Application.DTOs;

public class LoginRequestDto
{
    /// <summary>
    /// Accepts UserCode, Email, or Mobile Number for unified login.
    /// </summary>
    public string Identifier { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
