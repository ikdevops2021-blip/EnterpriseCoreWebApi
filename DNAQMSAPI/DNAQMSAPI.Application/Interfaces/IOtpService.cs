namespace DNAQMSAPI.Application.Interfaces;

public interface IOtpService
{
    Task<bool> SendOtpAsync(string destination, string provider); // SMS, Email, WhatsApp
    Task<bool> ValidateOtpAsync(string destination, string code);
}
