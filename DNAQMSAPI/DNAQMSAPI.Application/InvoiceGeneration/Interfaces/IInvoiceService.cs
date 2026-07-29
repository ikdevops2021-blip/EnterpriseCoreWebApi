using System;
using System.Threading;
using System.Threading.Tasks;
using DNAQMSAPI.Application.InvoiceGeneration.DTOs;

namespace DNAQMSAPI.Application.InvoiceGeneration.Interfaces;

public interface IInvoiceService
{
    Task<InvoiceModel?> GetInvoiceDetailsAsync(Guid invoiceId, CancellationToken cancellationToken = default);
    Task<string> GetInvoiceHtmlAsync(Guid invoiceId, CancellationToken cancellationToken = default);
}
