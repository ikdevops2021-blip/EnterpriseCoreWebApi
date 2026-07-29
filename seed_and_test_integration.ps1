$baseUrl = "https://localhost:7288"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

Write-Host "Seeding Integration Configuration..."
$configBody = @{
    Name = "TestProvider"
    BaseUrl = "https://jsonplaceholder.typicode.com"
    AuthType = 0
    IsGlobal = $true
    IsActive = $true
    CreatedBy = 1
} | ConvertTo-Json

try {
    $configResponse = Invoke-RestMethod -Uri "$baseUrl/api/v1/Integration/configure" -Method Post -Body $configBody -ContentType "application/json"
    Write-Host "Config Response: $($configResponse | ConvertTo-Json)" -ForegroundColor Green
} catch [System.Net.WebException] {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Config Error Body: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`nTesting test-send endpoint..."
$requestBody = @{
    ConfigName = "TestProvider"
    Endpoint = "/todos/1"
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
