using System;
using System.Threading.Tasks;
using DNAQMSAPI.Application.Email.DTOs;

namespace DNAQMSAPI.Application.Email.Interfaces;

public interface IEmailService
{
    Task<Guid> QueueEmailAsync(int centerId, EmailRequest request, int priority, int createdBy);
    Task<EmailSettingsDto?> GetEmailSettingsAsync(int organizationId);
    Task<int> SaveEmailSettingsAsync(EmailSettingsDto settings);
    Task<(bool Success, string Message)> TestSmtpConnectionAsync(MailServerConfig config);
}
