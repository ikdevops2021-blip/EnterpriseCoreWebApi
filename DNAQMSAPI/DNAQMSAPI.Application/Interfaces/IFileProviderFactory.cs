namespace DNAQMSAPI.Application.Interfaces;

public interface IFileProviderFactory
{
    IFileProvider GetProvider(string providerName);
}
