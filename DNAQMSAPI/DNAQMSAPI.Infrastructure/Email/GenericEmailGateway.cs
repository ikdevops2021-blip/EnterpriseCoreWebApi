using System;
using System.Threading.Tasks;
using DNAQMSAPI.Application.Email.DTOs;
using DNAQMSAPI.Application.Email.Interfaces;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace DNAQMSAPI.Infrastructure.Email;

public class GenericEmailGateway : IGenericEmailGateway
{
    public async Task<(bool Success, string Error)> SendEmailAsync(EmailRequest request, MailServerConfig config)
    {
        try
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(config.SenderDescription ?? config.SmtpUser, config.SmtpUser));
            
            foreach (var to in request.To)
                message.To.Add(MailboxAddress.Parse(to));
                
            foreach (var cc in request.Cc)
                message.Cc.Add(MailboxAddress.Parse(cc));
                
            foreach (var bcc in request.Bcc)
                message.Bcc.Add(MailboxAddress.Parse(bcc));

            message.Subject = request.Subject;

            var builder = new BodyBuilder
            {
                HtmlBody = request.HtmlBody,
                TextBody = request.TextBody
            };

            foreach (var attachment in request.Attachments)
            {
                builder.Attachments.Add(attachment.FileName, attachment.Content, ContentType.Parse(attachment.ContentType));
            }

            message.Body = builder.ToMessageBody();

            using var client = new SmtpClient();

            if (config.BypassCertificateValidation)
            {
                client.ServerCertificateValidationCallback = (s, c, h, e) => true;
            }

            var secureSocketOptions = config.EnableSSL ? SecureSocketOptions.StartTls : SecureSocketOptions.None;
            await client.ConnectAsync(config.SmtpHost, config.SmtpPort, secureSocketOptions);
            
            await client.AuthenticateAsync(config.SmtpUser, config.SmtpPass);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);

            return (true, string.Empty);
        }
        catch (Exception ex)
        {
            return (false, ex.Message);
        }
    }
}
