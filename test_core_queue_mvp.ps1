param(
    [string]$BaseUrl = "http://localhost:5026",
    [string]$ApiKey = "dnaqms_live_system_admin_key_112233"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  QA MANAGER END-TO-END VERIFICATION SUITE: CORE QUEUE MANAGEMENT MVP           " -ForegroundColor Cyan
Write-Host "  Target API: $BaseUrl                                                          " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$passed = 0
$failed = 0
$testResults = @()

function Run-Test {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers,
        [string]$Body,
        [int]$ExpectedStatusCode,
        [scriptblock]$Validator = $null
    )

    $url = "$BaseUrl$Endpoint"
    $status = 0
    $success = $false
    $message = ""
    $respObj = $null

    try {
        $reqHeaders = @{
            "Accept" = "application/json"
        }
        if ($Body) {
            $reqHeaders["Content-Type"] = "application/json"
        }
        if ($Headers) {
            foreach ($k in $Headers.Keys) {
                $reqHeaders[$k] = $Headers[$k]
            }
        }

        $params = @{
            Uri = $url
            Method = $Method
            Headers = $reqHeaders
            ErrorAction = "Stop"
        }
        if ($Body) {
            $params["Body"] = $Body
        }

        $rawResp = Invoke-WebRequest @params -UseBasicParsing -TimeoutSec 10
        $status = [int]$rawResp.StatusCode
        $respObj = $rawResp.Content | ConvertFrom-Json
    }
    catch {
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $content = $reader.ReadToEnd()
                $respObj = $content | ConvertFrom-Json
            } catch {}
        } else {
            $message = "Network / Connection error: $($_.Exception.Message)"
        }
    }

    if ($status -eq $ExpectedStatusCode) {
        if ($Validator -and $respObj) {
            $valResult = & $Validator $respObj
            if ($valResult.Valid) {
                $success = $true
                $message = "OK - $($valResult.Message)"
            } else {
                $success = $false
                $message = "Validation Failed: $($valResult.Message)"
            }
        } else {
            $success = $true
            $message = "OK (Status $status matches expected)"
        }
    } else {
        $success = $false
        $message = "Status mismatch: Got $status, Expected $ExpectedStatusCode"
    }

    if ($success) {
        $script:passed++
        Write-Host "  [PASS] [$Id] $Name => $message" -ForegroundColor Green
    } else {
        $script:failed++
        Write-Host "  [FAIL] [$Id] $Name => $message" -ForegroundColor Red
    }

    $script:testResults += [PSCustomObject]@{
        Id = $Id
        Name = $Name
        Method = $Method
        Endpoint = $Endpoint
        Expected = $ExpectedStatusCode
        Actual = $status
        Passed = $success
        Message = $message
    }

    return $respObj
}

# --- TEST 1: Security - Negative Login Test (Must reject invalid password with 401) ---
Run-Test -Id "AUTH-01" `
    -Name "Reject Invalid Password with 401 Unauthorized" `
    -Method "POST" `
    -Endpoint "/api/v1/auth/login" `
    -Body '{"identifier":"admin@dnaqms.com","password":"WrongPassword123!"}' `
    -ExpectedStatusCode 401 `
    -Validator {
        param($r)
        return @{ Valid = ($r.success -eq $false); Message = "Correctly rejected bad password" }
    }

# --- TEST 2: Security - Positive Login Test (Must authenticate with real JWT) ---
$loginResp = Run-Test -Id "AUTH-02" `
    -Name "Successful Login with Valid Credentials" `
    -Method "POST" `
    -Endpoint "/api/v1/auth/login" `
    -Body '{"identifier":"admin@dnaqms.com","password":"Welc0me@555"}' `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        $token = $r.data.token
        $isRealJwt = ($token -and $token.Length -gt 50 -and $token -notlike "MOCK_*")
        return @{ Valid = $isRealJwt; Message = "Generated genuine JWT: $($token.Substring(0, 20))..." }
    }

$jwtToken = $loginResp.data.token
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
    "X-Organization-Id" = "1"
}
$apiKeyHeaders = @{
    "X-Api-Key" = $ApiKey
    "X-Organization-Id" = "1"
}

# --- TEST 3: Admin Areas Master ---
Run-Test -Id "ADMIN-01" `
    -Name "Fetch Areas via Admin API" `
    -Method "GET" `
    -Endpoint "/api/v1/admin/areas?organizationId=1&locationId=1" `
    -Headers $authHeaders `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        $count = ($r.data | Measure-Object).Count
        return @{ Valid = ($r.success -and $count -gt 0); Message = "Retrieved $count areas" }
    }

# --- TEST 4: Admin Processes Master ---
Run-Test -Id "ADMIN-02" `
    -Name "Fetch Processes via Admin API" `
    -Method "GET" `
    -Endpoint "/api/v1/admin/processes?organizationId=1" `
    -Headers $authHeaders `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        $count = ($r.data | Measure-Object).Count
        return @{ Valid = ($r.success -and $count -gt 0); Message = "Retrieved $count service processes" }
    }

# --- TEST 5: Admin Counters Master ---
Run-Test -Id "ADMIN-03" `
    -Name "Fetch Counters via Admin API" `
    -Method "GET" `
    -Endpoint "/api/v1/admin/counters?organizationId=1&locationId=1" `
    -Headers $authHeaders `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        $count = ($r.data | Measure-Object).Count
        return @{ Valid = ($r.success -and $count -gt 0); Message = "Retrieved $count service counters" }
    }

# --- TEST 6: Admin Display Templates Master ---
Run-Test -Id "ADMIN-04" `
    -Name "Fetch Display Templates via Admin API" `
    -Method "GET" `
    -Endpoint "/api/v1/admin/templates?organizationId=1" `
    -Headers $authHeaders `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        $count = ($r.data | Measure-Object).Count
        return @{ Valid = ($r.success -and $count -gt 0); Message = "Retrieved $count display templates" }
    }

# --- TEST 7: Kiosk / Reception - Issue Ticket (Standard Endpoint) ---
$tknResp1 = Run-Test -Id "QUEUE-01" `
    -Name "Issue New Ticket (POST /api/v1/staff/issue-token)" `
    -Method "POST" `
    -Endpoint "/api/v1/staff/issue-token" `
    -Headers $apiKeyHeaders `
    -Body '{"organizationId":1,"locationId":1,"areaId":1,"processId":1,"priorityTier":19001,"customerName":"QA Patient Alpha","customerPhone":"+1234567890"}' `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        $id = $r.data.tokenId
        return @{ Valid = ($r.success -and $id -gt 0); Message = "Issued Token ID: $id" }
    }

$issuedTokenId = $tknResp1.data.tokenId

# --- TEST 8: Kiosk Route Alias - Issue Ticket (POST /api/v1/dqms/tickets) ---
Run-Test -Id "QUEUE-02" `
    -Name "Issue New Ticket via Route Alias (POST /api/v1/dqms/tickets)" `
    -Method "POST" `
    -Endpoint "/api/v1/dqms/tickets" `
    -Headers $apiKeyHeaders `
    -Body '{"organizationId":1,"locationId":1,"areaId":1,"processId":1,"priorityTier":19002,"customerName":"QA Senior Patient","customerPhone":"+1987654321"}' `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        $id = $r.data.tokenId
        return @{ Valid = ($r.success -and $id -gt 0); Message = "Issued Token ID via alias: $id" }
    }

# --- TEST 9: Public Overhead TV Display Board ---
Run-Test -Id "DISPLAY-01" `
    -Name "Get Public Display Board for Waiting Room" `
    -Method "GET" `
    -Endpoint "/api/v1/public/display-board?organizationId=1&locationId=1" `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        return @{ Valid = $r.success; Message = "Display board returned successfully" }
    }

# --- TEST 10: Public Mobile Ticket Tracking by ID ---
$issuedTokenNumber = ""
if ($issuedTokenId) {
    $trackResp = Run-Test -Id "TRACK-01" `
        -Name "Get Public Ticket Status by Numeric ID" `
        -Method "GET" `
        -Endpoint "/api/v1/public/ticket-status/$issuedTokenId" `
        -ExpectedStatusCode 200 `
        -Validator {
            param($r)
            return @{ Valid = ($r.success -and $r.data.tokenNumber); Message = "Tracking Token Number: $($r.data.tokenNumber), Customers Ahead: $($r.data.customersAhead)" }
        }
    if ($trackResp -and $trackResp.data) {
        $issuedTokenNumber = $trackResp.data.tokenNumber
    }
}

# --- TEST 11: Public Mobile Ticket Tracking by Alphanumeric Identifier ---
if ($issuedTokenNumber) {
    Run-Test -Id "TRACK-02" `
        -Name "Get Public Ticket Status by Alphanumeric Identifier ($issuedTokenNumber)" `
        -Method "GET" `
        -Endpoint "/api/v1/public/ticket-status/$issuedTokenNumber" `
        -ExpectedStatusCode 200 `
        -Validator {
            param($r)
            return @{ Valid = ($r.success -and $r.data.tokenNumber -eq $issuedTokenNumber); Message = "Successfully tracked by string code $issuedTokenNumber" }
        }
} else {
    Run-Test -Id "TRACK-02" `
        -Name "Get Public Ticket Status by Alphanumeric Identifier" `
        -Method "GET" `
        -Endpoint "/api/v1/public/ticket-status/A-001" `
        -ExpectedStatusCode 200 `
        -Validator {
            param($r)
            return @{ Valid = $r.success; Message = "Successfully tracked by string code A-001" }
        }
}

# --- TEST 12: Staff Counter Queue ---
Run-Test -Id "STAFF-01" `
    -Name "Get Staff Queue for Counter 1" `
    -Method "GET" `
    -Endpoint "/api/v1/staff/queue?organizationId=1&locationId=1&processId=1&counterId=1" `
    -Headers $authHeaders `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        return @{ Valid = $r.success; Message = "Counter queue loaded successfully" }
    }

# --- TEST 13: Staff Call Next Token ---
Run-Test -Id "STAFF-02" `
    -Name "Operator Calls Next Token" `
    -Method "POST" `
    -Endpoint "/api/v1/staff/call-next" `
    -Headers $authHeaders `
    -Body '{"organizationId":1,"locationId":1,"counterId":1,"processId":1,"staffUserId":1}' `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        return @{ Valid = $r.success; Message = "Call next executed successfully: $($r.message)" }
    }

# --- TEST 14: Staff Update Token Status (Serving / Completed) ---
if ($issuedTokenId) {
    Run-Test -Id "STAFF-03" `
        -Name "Operator Updates Token Status to Serving (18004)" `
        -Method "POST" `
        -Endpoint "/api/v1/staff/update-status" `
        -Headers $authHeaders `
        -Body "{`"tokenId`":$issuedTokenId,`"newStatus`":18004,`"staffUserId`":1,`"counterId`":1}" `
        -ExpectedStatusCode 200 `
        -Validator {
            param($r)
            return @{ Valid = $r.success; Message = "Status updated to Serving" }
        }

    Run-Test -Id "STAFF-04" `
        -Name "Operator Completes Token (18007)" `
        -Method "POST" `
        -Endpoint "/api/v1/staff/update-status" `
        -Headers $authHeaders `
        -Body "{`"tokenId`":$issuedTokenId,`"newStatus`":18007,`"staffUserId`":1,`"counterId`":1}" `
        -ExpectedStatusCode 200 `
        -Validator {
            param($r)
            return @{ Valid = $r.success; Message = "Status updated to Completed" }
        }
}

# --- TEST 15: Executive Reports Summary (GET) ---
Run-Test -Id "REPORT-01" `
    -Name "Executive Reports Summary (GET /api/v1/reports/summary)" `
    -Method "GET" `
    -Endpoint "/api/v1/reports/summary?organizationId=1&locationId=1" `
    -Headers $authHeaders `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        return @{ Valid = ($r.success -and $r.data.totalTokensIssued -ge 0); Message = "Executive summary loaded: $($r.data.totalTokensIssued) tokens recorded" }
    }

# --- TEST 16: Executive Reports Summary (POST) ---
Run-Test -Id "REPORT-02" `
    -Name "Executive Reports Summary (POST /api/v1/dqms/reports/summary)" `
    -Method "POST" `
    -Endpoint "/api/v1/dqms/reports/summary" `
    -Headers $authHeaders `
    -Body '{"organizationId":1,"locationId":1}' `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        return @{ Valid = ($r.success -and $r.data.totalTokensIssued -ge 0); Message = "POST Executive summary loaded successfully" }
    }

# --- TEST 17: Email Config ---
Run-Test -Id "CONFIG-01" `
    -Name "Email Config (GET /api/v1/Email/config)" `
    -Method "GET" `
    -Endpoint "/api/v1/Email/config?organizationId=1" `
    -Headers $authHeaders `
    -ExpectedStatusCode 200 `
    -Validator {
        param($r)
        return @{ Valid = $r.success; Message = "Email configuration endpoint operational" }
    }

$summaryColor = "Green"
if ($failed -gt 0) { $summaryColor = "Red" }
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  TEST SUITE SUMMARY: $passed PASSED, $failed FAILED (TOTAL: $($passed + $failed))" -ForegroundColor $summaryColor
Write-Host "================================================================================" -ForegroundColor Cyan

$testResults | Export-Csv -Path "qa_core_queue_mvp_results.csv" -NoTypeInformation
Write-Host "Detailed QA results saved to qa_core_queue_mvp_results.csv"
