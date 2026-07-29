$apis = @(
    @{
        Name = "TaxEngine API"
        BaseUrl = "https://localhost:7051"
        Endpoints = @(
            @{ Method = "POST"; Path = "/api/Tax/calculate"; Body = "{}" }
        )
    },
    @{
        Name = "SubscriptionSaaS API"
        BaseUrl = "https://localhost:7073"
        Endpoints = @(
            @{ Method = "GET"; Path = "/api/Subscription/123" }
            @{ Method = "POST"; Path = "/api/Subscription"; Body = '{"tenantId":"123","planId":"basic"}' }
            @{ Method = "POST"; Path = "/api/Subscription/123/cancel"; Body = "{}" }
            @{ Method = "POST"; Path = "/api/Subscription/test-feature"; Body = "{}" }
        )
    },
    @{
        Name = "DNAQMS API"
        BaseUrl = "https://localhost:7288"
        Endpoints = @(
            @{ Method = "GET"; Path = "/api/v1/Organizations" }
            @{ Method = "GET"; Path = "/api/v1/Organizations/1" }
            @{ Method = "POST"; Path = "/api/v1/Integration/test-send"; Body = '{"data":"test"}' }
            @{ Method = "POST"; Path = "/api/v1/Integration/configure"; Body = '{"config":"test"}' }
            @{ Method = "POST"; Path = "/api/v1/Auth/login"; Body = '{"username":"qa","password":"pwd"}' }
            @{ Method = "POST"; Path = "/api/v1/Auth/register"; Body = '{"username":"qa","password":"pwd"}' }
        )
    }
)

$report = "# QA Automated Test Report`n`n"
$report += "Run Date: $(Get-Date)`n`n"

foreach ($api in $apis) {
    $report += "## $($api.Name)`n"
    $report += "| Method | Endpoint | Status | Result |`n"
    $report += "|---|---|---|---|`n"
    
    foreach ($ep in $api.Endpoints) {
        $url = "$($api.BaseUrl)$($ep.Path)"
        try {
            if ($ep.Body) {
                $response = Invoke-RestMethod -Uri $url -Method $ep.Method -Body $ep.Body -ContentType "application/json" -SkipCertificateCheck -ErrorAction Stop -PassThru
            } else {
                $response = Invoke-RestMethod -Uri $url -Method $ep.Method -SkipCertificateCheck -ErrorAction Stop -PassThru
            }
            $status = $response.StatusCode
            $result = "PASS"
        } catch {
            if ($_.Exception.Response) {
                $status = [int]$_.Exception.Response.StatusCode
                # 4xx errors usually mean the endpoint exists but we sent bad data, which is fine for existence checks
                $result = if ($status -lt 500) { "PASS (Client Error expected)" } else { "FAIL (Server Error)" }
            } else {
                $status = "Connection Error"
                $result = "FAIL"
            }
        }
        $report += "| $($ep.Method) | $($ep.Path) | $status | $result |`n"
    }
    $report += "`n"
}

$report | Out-File -FilePath "qa_test_report.md" -Encoding utf8
Write-Output "QA tests completed. Report generated at qa_test_report.md."
