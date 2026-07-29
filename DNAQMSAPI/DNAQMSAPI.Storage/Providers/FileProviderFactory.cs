using DNAQMSAPI.Application.Interfaces;

namespace DNAQMSAPI.Storage.Providers;

public class FileProviderFactory : IFileProviderFactory
{
    private readonly IEnumerable<IFileProvider> _providers;

    public FileProviderFactory(IEnumerable<IFileProvider> providers)
    {
        _providers = providers;
    }

    public IFileProvider GetProvider(string providerName)
    {
        var provider = _providers.FirstOrDefault(p => string.Equals(p.ProviderName, providerName, StringComparison.OrdinalIgnoreCase));
        
        if (provider == null)
            throw new NotSupportedException($"Storage Provider '{providerName}' is not supported.");
            
        return provider;
    }
}
