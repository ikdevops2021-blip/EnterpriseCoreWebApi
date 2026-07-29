using System.Data;
using System.Security.Cryptography;
using System.Text;
using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.DTOs;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Domain.Entities;
using DNAQMSAPI.Infrastructure.Models;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Services;

public class UserService : IUserService
{
    private const int Pbkdf2Iterations = 100_000;
    private readonly DNAQMSAPI.Application.Interfaces.IDapperDBFactory _dbFactory;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;
    private readonly ILogger<UserService> _logger;

    public UserService(DNAQMSAPI.Application.Interfaces.IDapperDBFactory dbFactory, IJwtTokenGenerator jwtTokenGenerator, ILogger<UserService> logger)
    {
        _dbFactory = dbFactory;
        _jwtTokenGenerator = jwtTokenGenerator;
        _logger = logger;
    }

    public async Task<User?> GetUserByIdAsync(int userId)
    {
        var users = await _dbFactory.QueryAsync<User>(
            "PR_S_User",
            new { p_Id = userId, p_Email = "", p_UserCode = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return users.FirstOrDefault();
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        var users = await _dbFactory.QueryAsync<User>(
            "PR_S_User",
            new { p_Id = -1, p_Email = email, p_UserCode = "", p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return users.FirstOrDefault();
    }

    public async Task<User?> GetUserByUserCodeAsync(string userCode)
    {
        var users = await _dbFactory.QueryAsync<User>(
            "PR_S_User",
            new { p_Id = -1, p_Email = "", p_UserCode = userCode, p_IsActive = -1 },
            commandType: CommandType.StoredProcedure);

        return users.FirstOrDefault();
    }

    public async Task<User> CreateUserAsync(User user)
    {
        var parameters = new
        {
            p_Id = 0,
            p_UserCode = user.UserCode,
            p_TitleId = user.TitleId,
            p_FirstName = user.FirstName,
            p_LastName = user.LastName,
            p_DisplayName = user.DisplayName,
            p_GenderId = user.GenderId,
            p_ProfileImageUrl = user.ProfileImageUrl,
            p_Email = user.Email,
            p_PasswordHash = user.PasswordHash,
            p_IsActive = user.IsActive,
            p_UID = user.CreatedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_User",
            parameters,
            commandType: CommandType.StoredProcedure);

        var createdId = Convert.ToInt32(result?.ID ?? 0);
        if (createdId > 0)
        {
            return (await GetUserByIdAsync(createdId))!;
        }

        throw new InvalidOperationException(result?.ErrMsg ?? "Failed to create User.");
    }

    public async Task<bool> UpdateUserAsync(User user)
    {
        var parameters = new
        {
            p_Id = user.Id,
            p_UserCode = user.UserCode,
            p_TitleId = user.TitleId,
            p_FirstName = user.FirstName,
            p_LastName = user.LastName,
            p_DisplayName = user.DisplayName,
            p_GenderId = user.GenderId,
            p_ProfileImageUrl = user.ProfileImageUrl,
            p_Email = user.Email,
            p_PasswordHash = user.PasswordHash,
            p_IsActive = user.IsActive,
            p_UID = user.ModifiedBy
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_User",
            parameters,
            commandType: CommandType.StoredProcedure);

        return result != null && result.ErrNo == 0 && result.RowsCount > 0;
    }

    public async Task<bool> DeleteUserAsync(int userId)
    {
        var user = await GetUserByIdAsync(userId);
        if (user == null) return false;

        var parameters = new
        {
            p_Id = user.Id,
            p_UserCode = user.UserCode,
            p_TitleId = user.TitleId,
            p_FirstName = user.FirstName,
            p_LastName = user.LastName,
            p_DisplayName = user.DisplayName,
            p_GenderId = user.GenderId,
            p_ProfileImageUrl = user.ProfileImageUrl,
            p_Email = user.Email,
            p_PasswordHash = user.PasswordHash,
            p_IsActive = 0,
            p_UID = 0
        };

        var result = await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_User",
            parameters,
            commandType: CommandType.StoredProcedure);

        if (result != null && result.ErrNo == 0)
        {
            const string deleteSql = @"
                UPDATE `User`
                SET IsDeleted = 1,
                    DeletedBy = @DeletedBy,
                    DeletedDate = CURRENT_TIMESTAMP,
                    ModifiedBy = @ModifiedBy,
                    ModifiedDate = CURRENT_TIMESTAMP
                WHERE Id = @Id AND IsDeleted = 0";

            return await _dbFactory.ExecuteAsync(deleteSql, new
            {
                Id = userId,
                DeletedBy = 0,
                ModifiedBy = 0
            }) > 0;
        }

        return false;
    }

    public async Task<ApiResponse<string>> LoginAsync(string identifier, string password)
    {
        // Unified lookup: PR_S_User p_Email parameter matches both Email and UserCode
        var user = await GetUserByEmailAsync(identifier);
        if (user == null || !user.IsActive || user.IsDeleted == true)
        {
            return ApiResponse<string>.Fail("Invalid credentials.");
        }

        if (!VerifyPassword(password, user.PasswordHash))
        {
            return ApiResponse<string>.Fail("Invalid credentials.");
        }

        var token = _jwtTokenGenerator.GenerateToken(user, Array.Empty<string>(), Array.Empty<string>());
        return ApiResponse<string>.Ok(token, "Login successful.");
    }

    public async Task<ApiResponse<User>> RegisterAsync(RegisterRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
        {
            return ApiResponse<User>.Fail("Email and password are required.");
        }

        var existingUser = await GetUserByEmailAsync(request.Email);
        if (existingUser != null)
        {
            return ApiResponse<User>.Fail("A user with this email already exists.");
        }

        // UserCode defaults to Email if not provided; DisplayName auto-generated by SP if null
        var userCode = string.IsNullOrWhiteSpace(request.UserCode) ? request.Email.Trim() : request.UserCode.Trim();

        // Check for duplicate UserCode
        var existingByCode = await GetUserByUserCodeAsync(userCode);
        if (existingByCode != null)
        {
            return ApiResponse<User>.Fail($"UserCode '{userCode}' is already taken.");
        }

        var user = new User
        {
            UserCode = userCode,
            TitleId = request.TitleId,
            Email = request.Email.Trim(),
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            DisplayName = request.DisplayName,
            GenderId = request.GenderId,
            ProfileImageUrl = request.ProfileImageUrl?.Trim(),
            PasswordHash = HashPassword(request.Password),
            IsActive = true,
            CreatedBy = 0,
            ModifiedBy = 0,
            IsDeleted = false
        };

        var createdUser = await CreateUserAsync(user);
        return ApiResponse<User>.Ok(createdUser, "User registered successfully.");
    }

    private static string HashPassword(string password)
    {
        byte[] salt = RandomNumberGenerator.GetBytes(16);
        using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Pbkdf2Iterations, HashAlgorithmName.SHA256);
        byte[] hash = pbkdf2.GetBytes(32);

        byte[] hashBytes = new byte[49];
        hashBytes[0] = 0x01;
        Buffer.BlockCopy(salt, 0, hashBytes, 1, 16);
        Buffer.BlockCopy(hash, 0, hashBytes, 17, 32);

        return Convert.ToBase64String(hashBytes);
    }

    private static bool VerifyPassword(string password, string hashedPassword)
    {
        try
        {
            byte[] hashBytes = Convert.FromBase64String(hashedPassword);
            if (hashBytes.Length != 49 || hashBytes[0] != 0x01)
            {
                return false;
            }

            byte[] salt = new byte[16];
            Buffer.BlockCopy(hashBytes, 1, salt, 0, 16);

            byte[] storedSubkey = new byte[32];
            Buffer.BlockCopy(hashBytes, 17, storedSubkey, 0, 32);

            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Pbkdf2Iterations, HashAlgorithmName.SHA256);
            byte[] generatedSubkey = pbkdf2.GetBytes(32);

            return CryptographicOperations.FixedTimeEquals(storedSubkey, generatedSubkey);
        }
        catch
        {
            return false;
        }
    }
}
