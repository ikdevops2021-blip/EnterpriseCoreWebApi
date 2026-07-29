using System;
using System.Threading.Tasks;
using System.Data;
using System.Linq;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Application.Email.Interfaces;
using DNAQMSAPI.Application.Email.DTOs;
using DNAQMSAPI.Infrastructure.Models;

namespace DNAQMSAPI.Infrastructure.Email;

public class EmailService : IEmailService
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly IGenericEmailGateway _emailGateway;

    public EmailService(IDapperDBFactory dbFactory, IGenericEmailGateway emailGateway)
    {
        _dbFactory = dbFactory;
        _emailGateway = emailGateway;
    }

    public async Task<Guid> QueueEmailAsync(int centerId, EmailRequest request, int priority, int createdBy)
    {
        var queueId = Guid.NewGuid();
        
        await _dbFactory.QuerySingleAsync<SPResult>(
            "PR_IU_EmailQueue",
            new
            {
                p_QueueId = queueId.ToString(),
                p_CenterId = centerId,
                p_RecipientTo = request.To != null ? string.Join(",", request.To) : string.Empty,
                p_RecipientCc = request.Cc != null ? string.Join(",", request.Cc) : (string?)null,
                p_RecipientBcc = request.Bcc != null ? string.Join(",", request.Bcc) : (string?)null,
                p_Subject = request.Subject,
                p_Body = !string.IsNullOrEmpty(request.HtmlBody) ? request.HtmlBody : request.TextBody,
                p_IsHtml = !string.IsNullOrEmpty(request.HtmlBody),
                p_Priority = priority,
                p_UID = createdBy
            },
            commandType: CommandType.StoredProcedure);

        return queueId;
    }

    public async Task<EmailSettingsDto?> GetEmailSettingsAsync(int organizationId)
    {
        const string sql = @"
            SELECT SettingId, OrganizationId, SmtpHost, SmtpPort, SmtpUser, SmtpPass, 
                   SenderDescription, EnableSSL, BypassCertificateValidation, Active,
                   CreatedBy, CreateDate, ModifiedBy, ModifyDate
            FROM EmailSettings
            WHERE OrganizationId = @OrganizationId AND IsDeleted = 0
            ORDER BY Active DESC, SettingId DESC
            LIMIT 1";

        var result = await _dbFactory.QueryAsync<EmailSettingsDto>(sql, new { OrganizationId = organizationId });
        return result.FirstOrDefault();
    }

    public async Task<int> SaveEmailSettingsAsync(EmailSettingsDto settings)
    {
        const string updateExistingSql = @"
            UPDATE EmailSettings
            SET SmtpHost = @SmtpHost,
                SmtpPort = @SmtpPort,
                SmtpUser = @SmtpUser,
                SmtpPass = @SmtpPass,
                SenderDescription = @SenderDescription,
                EnableSSL = @EnableSSL,
                BypassCertificateValidation = @BypassCertificateValidation,
                Active = @Active,
                ModifiedBy = @ModifiedBy,
                ModifyDate = NOW()
            WHERE SettingId = @SettingId AND IsDeleted = 0";

        const string insertSql = @"
            INSERT INTO EmailSettings (
                OrganizationId, SmtpHost, SmtpPort, SmtpUser, SmtpPass, 
                SenderDescription, EnableSSL, BypassCertificateValidation, Active,
                CreatedBy, CreateDate, ModifiedBy, ModifyDate
            ) VALUES (
                @OrganizationId, @SmtpHost, @SmtpPort, @SmtpUser, @SmtpPass, 
                @SenderDescription, @EnableSSL, @BypassCertificateValidation, @Active,
                @CreatedBy, NOW(), @ModifiedBy, NOW()
            );
            SELECT LAST_INSERT_ID();";

        if (settings.SettingId > 0)
        {
            await _dbFactory.ExecuteAsync(updateExistingSql, settings);
            return settings.SettingId;
        }
        else
        {
            var insertedId = await _dbFactory.QuerySingleAsync<int>(insertSql, settings);
            return insertedId;
        }
    }

    public async Task<(bool Success, string Message)> TestSmtpConnectionAsync(MailServerConfig config)
    {
        var testRequest = new EmailRequest
        {
            To = new System.Collections.Generic.List<string> { config.SmtpUser },
            Subject = "DNAQMS API - SMTP Health Check",
            TextBody = "This is an automated connection test message from DNAQMS Web API."
        };

        var result = await _emailGateway.SendEmailAsync(testRequest, config);
        if (result.Success)
        {
            return (true, "SMTP Server connection test succeeded.");
        }

        return (false, $"SMTP Connection Failed: {result.Error}");
    }
}
