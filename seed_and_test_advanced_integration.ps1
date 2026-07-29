$baseUrl = "https://localhost:7288"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

Write-Host "Seeding Data..."

$sql = @"
USE dnaqms;
DELETE FROM APIIntegrations WHERE ProviderName = 'Typicode';
INSERT INTO APIIntegrations (CenterID, ProviderName, BaseUrl, Active, AuditLevel, AuthType, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
VALUES (1, 'Typicode', 'https://jsonplaceholder.typicode.com', 1, 2, 0, 1, NOW(), 1, NOW(), 0);
SET @IntegrationID = LAST_INSERT_ID();

DELETE FROM ApiEndpoints WHERE ActionName = 'GetTodo';
INSERT INTO ApiEndpoints (IntegrationID, ActionName, RelativePath, HttpMethod, Active, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
VALUES (@IntegrationID, 'GetTodo', '/todos/{id}', 'GET', 1, 1, NOW(), 1, NOW(), 0);
"@

Set-Content -Path "seed.sql" -Value $sql
mysql.exe -u root -pmysql -D dnaqms -e "source seed.sql"

Write-Host "Data Seeded. Testing test-send endpoint..."

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
