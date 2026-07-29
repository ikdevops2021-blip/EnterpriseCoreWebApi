namespace DNAQMSAPI.Domain.SubscriptionSaaS.Entities;

public class PlanFeature
{
    public int FeatureId { get; set; }
    public int PlanId { get; set; }
    public string FeatureKey { get; set; } = string.Empty;
    public string FeatureValue { get; set; } = string.Empty;
}
