namespace DNAQMSAPI.Domain.Enums;

public enum PaymentStatus
{
    Created,
    Pending,
    Authorized,
    Captured,
    Success,
    Completed,
    Failed,
    Cancelled,
    Expired,
    RefundRequested,
    RefundProcessing,
    RefundCompleted,
    PartialRefund,
    Chargeback,
    Disputed,
    SettlementPending,
    Settled,
    Reconciled
}
