namespace DNAQMSAPI.Application.DTOs;

public class RegisterRequestDto
{
    public string? UserCode { get; set; }
    public int? TitleId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public int? GenderId { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class UserDto
{
    public int Id { get; set; }
    public string UserCode { get; set; } = string.Empty;
    public int? TitleId { get; set; }
    public string? TitleName { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public int? GenderId { get; set; }
    public string? GenderName { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string Email { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}

public class UpdateUserRequestDto
{
    public string? UserCode { get; set; }
    public int? TitleId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public int? GenderId { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string Email { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}
