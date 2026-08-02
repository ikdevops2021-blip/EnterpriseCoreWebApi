$server = "Server=(localdb)\MSSQLLocalDB;Integrated Security=true"
$dbName = "DNAQMSDB"
$baseDir = "e:\MySourceCodes\AntiGravity_Projects\WebAPIs\antigravity-enterprise\DNAQMSAPI\DatabaseScripts\MSSQLScript"

try {
    Add-Type -AssemblyName System.Data
    $conn = New-Object System.Data.SqlClient.SqlConnection($server)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Host "Dropping and recreating database dnaqms and DNAQMSDB..."
    $cmd.CommandText = "IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'dnaqms') DROP DATABASE [dnaqms]; CREATE DATABASE [dnaqms]; IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'DNAQMSDB') DROP DATABASE [DNAQMSDB]; CREATE DATABASE [DNAQMSDB];"
    $cmd.ExecuteNonQuery() | Out-Null
    
    $cmd.CommandText = "USE [dnaqms];"
    $cmd.ExecuteNonQuery() | Out-Null

    $scripts = @(
        "17_NexusCore_Config.sql",
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
        "12_StoredFile.sql",
        "Integration\001_ThirdPartyApiConfig.sql",
        "Integration\002_Integration_StoredProcedures.sql",
        "14_Integration_Tables.sql",
        "15_Integration_Indexes.sql",
        "18_NexusCore_Config_StoredProcs.sql",
        "19_NexusCore_ID_Generator.sql",
        "21_NexusCore_SeedData.sql",
        "22_UserContactAndAddress.sql",
        "27_Location_And_UserProfile_StoredProcs.sql",
        "28_Alter_User_Add_UserCode.sql",
        "31_DQMS_Admin_Masters.sql",
        "32_DQMS_Seed_ConfigParameters.sql",
        "29_Notification_Tables.sql",
        "30_Notification_StoredProcs.sql",
        "33_DQMS_Staff_Operations.sql",
        "34_DQMS_Customer_Display.sql",
        "Payments\001_OrganizationPaymentProvider.sql",
        "Payments\002_PaymentTransaction.sql",
        "99_DummyData.sql",
        "100_Integration_SeedData.sql",
        "101_CreateUserAuthAndPermissions.sql",
        "102_ProvisionApiKeysAllUsers.sql",
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
