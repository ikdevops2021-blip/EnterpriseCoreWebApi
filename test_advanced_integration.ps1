$baseUrl = "https://localhost:7288"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

Write-Host "`nTesting test-send endpoint..."

$requestBody = @{
    TenantId = 1
    ExecutingUserId = 1
    ProviderName = "Typicode"
    ActionName = "GetTodo"
    RouteParameters = @{
        "id" = "1"
    }
} | ConvertTo-Json

try {
    $sendResponse = Invoke-RestMethod -Uri "$baseUrl/api/v1/Integration/test-send" -Method Post -Body $requestBody -ContentType "application/json"
    Write-Host "Test Send Response: $($sendResponse | ConvertTo-Json -Depth 10)" -ForegroundColor Green
    Write-Host "SUCCESS! Integration test-send passed." -ForegroundColor Cyan
} catch [System.Net.WebException] {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Error Body: $responseBody" -ForegroundColor Yellow
    }
}
