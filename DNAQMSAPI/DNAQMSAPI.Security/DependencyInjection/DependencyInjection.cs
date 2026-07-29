using AntiGravity.Enterprise.Shared.Core.Models;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Security.Authentication;
using DNAQMSAPI.Security.Authorization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace DNAQMSAPI.Security.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddSecurityServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<RequestContext>();
        services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
        services.AddScoped<IAuthorizationEngine, AuthorizationEngine>();
        services.AddAuthorization();

        var jwtSettings = configuration.GetSection("JwtSettings");
        var secret = jwtSettings["Secret"] ?? throw new InvalidOperationException("JwtSettings:Secret is required.");
        var issuer = jwtSettings["Issuer"];
        var audience = jwtSettings["Audience"];

        services.AddAuthentication(options =>
        {
            options.DefaultScheme = "BearerOrApiKey";
            options.DefaultAuthenticateScheme = "BearerOrApiKey";
            options.DefaultChallengeScheme = "BearerOrApiKey";
        })
        .AddPolicyScheme("BearerOrApiKey", "Bearer or ApiKey", options =>
        {
            options.ForwardDefaultSelector = context =>
            {
                if (context.Request.Headers.ContainsKey("x-api-key") || 
                    context.Request.Headers.ContainsKey("ApiKey") ||
                    context.Request.Headers.ContainsKey(ApiKeyAuthenticationOptions.DefaultScheme))
                {
                    return ApiKeyAuthenticationOptions.DefaultScheme;
                }

                return JwtBearerDefaults.AuthenticationScheme;
            };
        })
        .AddJwtBearer(options =>
        {
            options.RequireHttpsMetadata = false;
            options.SaveToken = true;
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = !string.IsNullOrWhiteSpace(issuer),
                ValidIssuer = issuer,
                ValidateAudience = !string.IsNullOrWhiteSpace(audience),
                ValidAudience = audience,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            };
        })
        .AddScheme<ApiKeyAuthenticationOptions, ApiKeyAuthenticationHandler>(ApiKeyAuthenticationOptions.DefaultScheme, options => { });
        
        // Register other implementations like IOtpService here
        
        return services;
    }
}
