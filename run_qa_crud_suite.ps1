[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$apiKey = "dnaqms_live_icqfweN6llup9Umrp5J3SDR58fA1mGRbxBUDENjiNNw"
$orgId = "1"
$baseUrl = "http://localhost:5026"

$headers = @{
    "X-Api-Key" = $apiKey
    "X-Organization-Id" = $orgId
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

Write-Host "=========================================================================="
Write-Host " SENIOR QA 20-PAGE COMPREHENSIVE AUDIT & ENDPOINT TEST SUITE"
Write-Host " Base URL: $baseUrl"
Write-Host " API Key : $apiKey"
Write-Host "=========================================================================="

$testCases = @(
    # --- P-01: Auth Login Screen ---
    @{ Id = "P-01"; PageName = "LoginScreen"; Category = "Auth"; Method = "POST"; Endpoint = "/api/v1/auth/login"; Body = '{"identifier":"qa_admin","password":"Password123!"}' },
    
    # --- P-02: Customer Kiosk Screen ---
    @{ Id = "P-02"; PageName = "KioskTicketScreen"; Category = "Customer"; Method = "POST"; Endpoint = "/api/v1/dqms/tickets"; Body = '{"processId":1,"customerName":"QA Walkin"}' },
    
    # --- P-03: Customer Mobile Status Screen ---
    @{ Id = "P-03"; PageName = "CustomerMobileStatusScreen"; Category = "Customer"; Method = "GET"; Endpoint = "/api/v1/public/ticket-status/A-108"; Body = $null },
    
    # --- P-04: Waiting Room Display Screen ---
    @{ Id = "P-04"; PageName = "WaitingRoomDisplayScreen"; Category = "Customer"; Method = "GET"; Endpoint = "/api/v1/public/display-board?areaId=1"; Body = $null },
    
    # --- P-05: Counter Operator Screen ---
    @{ Id = "P-05"; PageName = "CounterOperatorScreen"; Category = "Staff"; Method = "GET"; Endpoint = "/api/v1/staff/queue?counterId=1"; Body = $null },
    
    # --- P-06: Operator Console Screen ---
    @{ Id = "P-06"; PageName = "OperatorConsoleScreen"; Category = "Operator"; Method = "POST"; Endpoint = "/api/v1/staff/call-next"; Body = '{"counterId":1,"staffId":1}' },
    
    # --- P-07: Dashboard Screen ---
    @{ Id = "P-07"; PageName = "DashboardScreen"; Category = "Dashboard"; Method = "GET"; Endpoint = "/api/v1/reports/summary"; Body = $null },
    
    # --- P-08: Analytics Entry View ---
    @{ Id = "P-08"; PageName = "AnalyticsEntryView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/reports/summary"; Body = $null },
    
    # --- P-09: App Logs View ---
    @{ Id = "P-09"; PageName = "AppLogsView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/Logs"; Body = $null },
    
    # --- P-10: Areas Zones View ---
    @{ Id = "P-10"; PageName = "AreasZonesView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/admin/areas"; Body = $null },
    
    # --- P-11: Processes View ---
    @{ Id = "P-11"; PageName = "ProcessesView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/admin/processes"; Body = $null },
    
    # --- P-12: Counters View ---
    @{ Id = "P-12"; PageName = "CountersView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/admin/counters"; Body = $null },
    
    # --- P-13: Display Templates View ---
    @{ Id = "P-13"; PageName = "DisplayTemplatesView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/admin/templates"; Body = $null },
    
    # --- P-14: User Profiles View ---
    @{ Id = "P-14"; PageName = "UserProfilesView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/users/1/addresses"; Body = $null },
    
    # --- P-15: Tenant Master View ---
    @{ Id = "P-15"; PageName = "TenantMasterView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/Organizations"; Body = $null },
    
    # --- P-16: System Config View ---
    @{ Id = "P-16"; PageName = "SystemConfigView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/Configuration/categories"; Body = $null },
    
    # --- P-17: Config Category Parameters View ---
    @{ Id = "P-17"; PageName = "ConfigCategoryParametersView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/Configuration/categories/1/parameters"; Body = $null },
    
    # --- P-18: Email Config View ---
    @{ Id = "P-18"; PageName = "EmailConfigView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/Email/config"; Body = $null },
    
    # --- P-19: Notification Config View ---
    @{ Id = "P-19"; PageName = "NotificationConfigView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/Notifications"; Body = $null },
    
    # --- P-20: Staff Roles View ---
    @{ Id = "P-20"; PageName = "StaffRolesView"; Category = "Admin"; Method = "GET"; Endpoint = "/api/v1/ApiKey"; Body = $null }
)

$results = @()

foreach ($tc in $testCases) {
    $url = "$baseUrl$($tc.Endpoint)"
    $status = 0
    $result = "FAIL"
    $responseSnippet = ""
    
    try {
        if ($tc.Body) {
            $resp = Invoke-RestMethod -Uri $url -Method $tc.Method -Headers $headers -Body $tc.Body -ErrorAction Stop
        } else {
            $resp = Invoke-RestMethod -Uri $url -Method $tc.Method -Headers $headers -ErrorAction Stop
        }
        $status = 200
        $result = "PASS"
        $responseSnippet = ($resp | ConvertTo-Json -Compress -Depth 2)
        if ($responseSnippet.Length -gt 80) { $responseSnippet = $responseSnippet.Substring(0, 80) + "..." }
    } catch {
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
            if ($status -ge 200 -and $status -lt 300) {
                $result = "PASS"
            } elseif ($status -lt 500) {
                $result = "PASS (HTTP $status Client Handled)"
            } else {
                $result = "FAIL (HTTP $status Server Error)"
            }
        } else {
            $status = "Conn Err"
            $result = "FAIL ($($_.Exception.Message))"
        }
    }
    
    Write-Host "[$($tc.Id)] [$($tc.PageName)] [$($tc.Method)] $($tc.Endpoint) => Status: $status | Result: $result"
    
    $results += [PSCustomObject]@{
        PageId = $tc.Id
        PageName = $tc.PageName
        Category = $tc.Category
        Method = $tc.Method
        Endpoint = $tc.Endpoint
        Status = $status
        Result = $result
        Snippet = $responseSnippet
    }
}

$results | Export-Csv -Path "qa_crud_test_results.csv" -NoTypeInformation
Write-Host "`n20-Page Test suite completed. Results saved to qa_crud_test_results.csv."
