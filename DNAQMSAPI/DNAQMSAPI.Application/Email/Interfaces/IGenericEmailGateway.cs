using System.Threading.Tasks;
using DNAQMSAPI.Application.Email.DTOs;

namespace DNAQMSAPI.Application.Email.Interfaces;

public interface IGenericEmailGateway
{
    Task<(bool Success, string Error)> SendEmailAsync(EmailRequest request, MailServerConfig config);
}
