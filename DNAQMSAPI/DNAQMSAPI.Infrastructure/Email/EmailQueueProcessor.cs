using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Data;
using DNAQMSAPI.Application.Interfaces;
using DNAQMSAPI.Application.Email.Interfaces;
using DNAQMSAPI.Application.Email.DTOs;
using Microsoft.Extensions.Logging;

namespace DNAQMSAPI.Infrastructure.Email;

public class EmailQueueProcessor : IEmailQueueProcessor
{
    private readonly IDapperDBFactory _dbFactory;
    private readonly IGenericEmailGateway _emailGateway;
    private readonly ILogger<EmailQueueProcessor> _logger;

    public EmailQueueProcessor(IDapperDBFactory dbFactory, IGenericEmailGateway emailGateway, ILogger<EmailQueueProcessor> logger)
    {
        _dbFactory = dbFactory;
        _emailGateway = emailGateway;
        _logger = logger;
    }

    public async Task ProcessQueueAsync(CancellationToken cancellationToken)
    {
        try
        {
            var fetchSql = @"
                SELECT TOP 50 
                    QueueId, CenterId, RecipientTo, RecipientCc, RecipientBcc, Subject, Body, IsHtml, RetryCount
                FROM EmailQueue
                WHERE Status = 0 AND IsDeleted = 0
                ORDER BY Priority DESC, CreateDate ASC";

            var pendingEmails = await _dbFactory.QueryAsync<dynamic>(fetchSql, commandType: CommandType.Text);

            if (!pendingEmails.Any())
                return;

            foreach (var email in pendingEmails)
            {
                if (cancellationToken.IsCancellationRequested)
                    break;

                if (email == null) continue;

                var centerId = (int)email.CenterId;
                
                var settingsSql = @"
                    SELECT SmtpHost, SmtpPort, SmtpUser, SmtpPass, SenderDescription, EnableSSL, BypassCertificateValidation
                    FROM EmailSettings
                    WHERE CenterId = @CenterId AND Active = 1 AND IsDeleted = 0";

                var settings = await _dbFactory.QuerySingleAsync<MailServerConfig>(settingsSql, new { CenterId = centerId }, commandType: CommandType.Text);

                if (settings == null)
                {
                    _logger.LogWarning($"No active email settings found for CenterId: {centerId}");
                    await UpdateQueueStatusAsync((Guid)email.QueueId, 2, "No active email settings found.");
                    continue;
                }

                var request = new EmailRequest
                {
                    To = ((string)email.RecipientTo).Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries).ToList(),
                    Subject = (string)email.Subject,
                };
                
                if (email.RecipientCc != null)
                    request.Cc = ((string)email.RecipientCc).Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries).ToList();
                    
                if (email.RecipientBcc != null)
                    request.Bcc = ((string)email.RecipientBcc).Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries).ToList();

                if ((bool)email.IsHtml)
                    request.HtmlBody = (string)email.Body;
                else
                    request.TextBody = (string)email.Body;

                var (success, error) = await _emailGateway.SendEmailAsync(request, settings);

                if (success)
                {
                    await UpdateQueueStatusAsync((Guid)email.QueueId, 1, null);
                }
                else
                {
                    var retryCount = (int)email.RetryCount + 1;
                    var status = retryCount >= 3 ? 2 : 0; // Fail after 3 retries, else leave pending
                    await UpdateQueueStatusAsync((Guid)email.QueueId, status, error, retryCount);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred while processing the email queue.");
        }
    }

    private async Task UpdateQueueStatusAsync(Guid queueId, int status, string? errorDescription, int retryCount = 0)
    {
        var sql = @"
            UPDATE EmailQueue 
            SET Status = @Status, ErrorDescription = @Error, RetryCount = @RetryCount, ModifyDate = GETDATE()
            WHERE QueueId = @QueueId";

        await _dbFactory.ExecuteAsync(sql, new { Status = status, Error = errorDescription, RetryCount = retryCount, QueueId = queueId }, commandType: CommandType.Text);
    }
}
