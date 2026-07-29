$server = "Server=(localdb)\MSSQLLocalDB;Integrated Security=true"
$dbName = "DNAQMSDB"
$baseDir = "e:\MySourceCodes\AntiGravity_Projects\WebAPIs\antigravity-enterprise\DNAQMSAPI\DatabaseScripts\MSSQLScript"

try {
    Add-Type -AssemblyName System.Data
    $conn = New-Object System.Data.SqlClient.SqlConnection($server)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Host "Dropping and recreating database $dbName..."
    $cmd.CommandText = "IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'$dbName') DROP DATABASE [$dbName]; CREATE DATABASE [$dbName];"
    $cmd.ExecuteNonQuery() | Out-Null
    
    $cmd.CommandText = "USE [$dbName];"
    $cmd.ExecuteNonQuery() | Out-Null

    $scripts = @(
        "01_Organization.sql",
        "02_User.sql",
        "03_Role.sql",
        "04_Permission.sql",
        "05_UserOrganization.sql",
        "06_UserRole.sql",
        "07_ApiKey.sql",
        "08_UserSession.sql",
        "09_UserDevice.sql",
        "10_OrganizationStorageConfig.sql",
        "11_OrganizationPaymentProvider.sql",
        "12_StoredFile.sql",
        "13_PaymentTransaction.sql",
        "14_Integration_Tables.sql",
        "15_Integration_Indexes.sql",
        "99_DummyData.sql",
        "100_Integration_SeedData.sql",
        "Email\001_EmailSettings.sql",
        "Email\002_EmailQueue.sql",
        "Email\003_EmailSignatures.sql",
        "Email\004_EmailViews.sql",
        "Email\005_EmailDummyData.sql"
    )

    foreach ($script in $scripts) {
        $path = Join-Path $baseDir $script
        if (Test-Path $path) {
            Write-Host "Executing $script..."
            $sql = Get-Content $path -Raw
            $batches = [Regex]::Split($sql, '^\s*GO\s*$', [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            foreach ($batch in $batches) {
                if (-not [string]::IsNullOrWhiteSpace($batch)) {
                    $cmd.CommandText = $batch
                    $cmd.ExecuteNonQuery() | Out-Null
                }
            }
        } else {
            Write-Host "WARNING: Script not found: $script"
        }
    }
    Write-Host "Database Initialization Complete!"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
