$baseUrl = "http://localhost:5026"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/v1/Integration/migrate" -Method Post -ContentType "application/json"
    Write-Host "Migration successful: $response" -ForegroundColor Green
} catch [System.Net.WebException] {
    Write-Host "Migration Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Error Body: $responseBody" -ForegroundColor Yellow
    }
}
