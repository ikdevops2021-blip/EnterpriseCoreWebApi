using Microsoft.OpenApi.Models;
using Microsoft.Extensions.DependencyInjection;

namespace DNAQMSAPI.Api.Extensions;

public static class SwaggerServiceExtensions
{
    public static IServiceCollection AddSwaggerDocumentation(this IServiceCollection services)
    {
        services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "DNAQMSAPI - Enterprise Multi-Tenant SaaS",
                Version = "v1",
                Description = "High Performance, Zero Trust compliant generic SaaS API."
            });

            // JWT Security Definition
            c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Description = @"JWT Authorization header using the Bearer scheme. 
                      Enter 'Bearer' [space] and then your token in the text input below.
                      Example: 'Bearer 12345abcdef'",
                Name = "Authorization",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.ApiKey,
                Scheme = "Bearer"
            });

            // ApiKey Security Definition
            c.AddSecurityDefinition("ApiKey", new OpenApiSecurityScheme
            {
                Description = "API Key Authorization header.\r\n\r\n Enter your API Key in the text input below.\r\n\r\nExample: \"dnaqms_live_12345abcdef\"",
                Name = "x-api-key",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.ApiKey,
                Scheme = "ApiKeyScheme"
            });

            // Multi-Tenant Organization Header
            c.AddSecurityDefinition("X-Organization-Id", new OpenApiSecurityScheme
            {
                Description = "Target Organization ID for Multi-Tenant operations.",
                Name = "X-Organization-Id",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.ApiKey
            });

            // Center Header
            c.AddSecurityDefinition("X-Center-Id", new OpenApiSecurityScheme
            {
                Description = "Target Center ID for Multi-Location operations.",
                Name = "X-Center-Id",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.ApiKey
            });

            c.AddSecurityRequirement(new OpenApiSecurityRequirement()
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        },
                        Scheme = "oauth2",
                        Name = "Bearer",
                        In = ParameterLocation.Header,
                    },
                    new List<string>()
                },
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "ApiKey"
                        },
                        Scheme = "ApiKeyScheme",
                        Name = "x-api-key",
                        In = ParameterLocation.Header,
                    },
                    new List<string>()
                },
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "X-Organization-Id"
                        },
                        In = ParameterLocation.Header,
                    },
                    new List<string>()
                },
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "X-Center-Id"
                        },
                        In = ParameterLocation.Header,
                    },
                    new List<string>()
                }
            });
        });

        return services;
    }
}
