[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy2 : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy2

try {
    Invoke-RestMethod -Uri "https://localhost:7288/api/v1/Integration/test-send" -Method POST -Body '{"data":"test"}' -ContentType "application/json" -ErrorAction Stop
} catch {
    Write-Host "Status Code:" $_.Exception.Response.StatusCode
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    Write-Host "Response Body:" $reader.ReadToEnd()
}
