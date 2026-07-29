using DNAQMSAPI.Application.Integration.DTOs;

namespace DNAQMSAPI.Application.Integration.Interfaces;

public interface IGenericApiClient
{
    Task<T?> SendAsync<T>(ApiRequest request);
}
