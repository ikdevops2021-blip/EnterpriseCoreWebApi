using System.Threading;
using System.Threading.Tasks;

namespace DNAQMSAPI.Application.Email.Interfaces;

public interface IEmailQueueProcessor
{
    Task ProcessQueueAsync(CancellationToken cancellationToken);
}
