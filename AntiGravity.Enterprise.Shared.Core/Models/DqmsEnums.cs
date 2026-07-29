namespace AntiGravity.Enterprise.Shared.Core.Enums
{
    /// <summary>
    /// Global Search Active Status: 0 -> Deactive | 1 -> Active | 2 -> All
    /// </summary>
    public enum e_ActiveSearchStatus
    {
        Deactive = 0,
        Active = 1,
        All = 2
    }

    /// <summary>
    /// Global Search Delete Status: 0 -> Not Deleted | 1 -> Deleted | 2 -> All
    /// </summary>
    public enum e_DeleteSearchStatus
    {
        NotDeleted = 0,
        Deleted = 1,
        All = 2
    }

    /// <summary>
    /// Maps to ConfigCategory = 18 (C_TOKEN_STATUS) in ConfigParameters table.
    /// </summary>
    public enum e_TokenStatus
    {
        Queued = 18001,
        Waiting = 18002,
        Calling = 18003,
        Active = 18004,
        Hold = 18005,
        Canceled = 18006,
        Completed = 18007,
        Forwarded = 18008
    }

    /// <summary>
    /// Maps to ConfigCategory = 19 (C_PRIORITY_TIER) in ConfigParameters table.
    /// </summary>
    public enum e_PriorityTier
    {
        Standard = 19001,
        SeniorCitizen = 19002,
        Disabled = 19003,
        Emergency = 19004,
        Vip = 19005
    }

    /// <summary>
    /// Maps to ConfigCategory = 20 (C_COUNTER_STATUS) in ConfigParameters table.
    /// </summary>
    public enum e_CounterStatus
    {
        Idle = 20001,
        Serving = 20002,
        Break = 20003,
        Offline = 20004
    }

    /// <summary>
    /// Maps to ConfigCategory = 21 (C_DISPLAY_TEMPLATE_TYPE) in ConfigParameters table.
    /// </summary>
    public enum e_DisplayTemplateType
    {
        GridView = 21001,
        SplitScreenVideo = 21002,
        HighDensityList = 21003,
        AudioVisualBanner = 21004
    }
}
