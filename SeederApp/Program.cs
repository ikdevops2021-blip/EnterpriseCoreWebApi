using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using MySqlConnector;

class AuthTester
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("==================================================");
        Console.WriteLine("        CHECKING USER DATA & AUTHENTICATION      ");
        Console.WriteLine("==================================================");

        string connStr = "Server=127.0.0.1;Port=3306;Database=dnaqms;Uid=root;Pwd=mysql;";
        using var conn = new MySqlConnection(connStr);
        await conn.OpenAsync();

        // 1. Check User table count
        using var countCmd = conn.CreateCommand();
        countCmd.CommandText = "SELECT COUNT(*) FROM `User` WHERE IsDeleted=0;";
        long userCount = (long)(await countCmd.ExecuteScalarAsync() ?? 0);
        Console.WriteLine($"Current Active User count in DB: {userCount}");

        // 2. Check ApiKey table count
        using var keyCountCmd = conn.CreateCommand();
        keyCountCmd.CommandText = "SELECT COUNT(*) FROM ApiKey WHERE IsDeleted=0;";
        long keyCount = (long)(await keyCountCmd.ExecuteScalarAsync() ?? 0);
        Console.WriteLine($"Current Active ApiKey count in DB: {keyCount}");

        string baseUrl = "http://localhost:5026";
        var handler = new HttpClientHandler
        {
            ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => true
        };
        using var client = new HttpClient(handler) { BaseAddress = new Uri(baseUrl) };

        string testEmail = "testuser@example.com";
        string testPassword = "TestPassword123!";

        // 3. Register user if needed
        Console.WriteLine($"\n1. Registering test user '{testEmail}'...");
        var regPayload = new
        {
            firstName = "Test",
            lastName = "User",
            email = testEmail,
            password = testPassword
        };
        var regContent = new StringContent(JsonSerializer.Serialize(regPayload), Encoding.UTF8, "application/json");
        var regResp = await client.PostAsync("/api/v1/Auth/register", regContent);
        string regJson = await regResp.Content.ReadAsStringAsync();
        Console.WriteLine($"Register Status: {regResp.StatusCode}");
        Console.WriteLine($"Register Response: {regJson}");

        // 4. Test Login (JWT Generation)
        Console.WriteLine($"\n2. Testing User Login (JWT)...");
        var loginPayload = new
        {
            email = testEmail,
            password = testPassword
        };
        var loginContent = new StringContent(JsonSerializer.Serialize(loginPayload), Encoding.UTF8, "application/json");
        var loginResp = await client.PostAsync("/api/v1/Auth/login", loginContent);
        string loginJson = await loginResp.Content.ReadAsStringAsync();
        Console.WriteLine($"Login Status: {loginResp.StatusCode}");
        Console.WriteLine($"Login Response: {loginJson}");

        string token = "";
        using (var doc = JsonDocument.Parse(loginJson))
        {
            if (doc.RootElement.TryGetProperty("data", out var dataElem) && dataElem.ValueKind == JsonValueKind.String)
            {
                token = dataElem.GetString() ?? "";
            }
        }

        if (string.IsNullOrEmpty(token))
        {
            Console.WriteLine("ERROR: JWT Token not retrieved. Aborting JWT and ApiKey tests.");
            return;
        }

        Console.WriteLine($"--> SUCCESS: JWT Token successfully retrieved! Length: {token.Length}");

        // 5. Test Authenticated Request using JWT Bearer Token
        Console.WriteLine($"\n3. Testing Protected Endpoint (/api/v1/Organizations) with JWT Bearer...");
        using var jwtReq = new HttpRequestMessage(HttpMethod.Get, "/api/v1/Organizations");
        jwtReq.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
        var jwtResp = await client.SendAsync(jwtReq);
        Console.WriteLine($"JWT Auth Status: {jwtResp.StatusCode}");
        Console.WriteLine($"JWT Auth Response: {await jwtResp.Content.ReadAsStringAsync()}");

        // 6. Test ApiKey Generation & Auth
        Console.WriteLine($"\n4. Generating API Key using JWT Token...");
        using var apiKeyGenReq = new HttpRequestMessage(HttpMethod.Post, "/api/v1/ApiKey?name=IntegrationTestKey");
        apiKeyGenReq.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
        var apiKeyGenResp = await client.SendAsync(apiKeyGenReq);
        string apiKeyGenJson = await apiKeyGenResp.Content.ReadAsStringAsync();
        Console.WriteLine($"ApiKey Gen Status: {apiKeyGenResp.StatusCode}");
        Console.WriteLine($"ApiKey Gen Response: {apiKeyGenJson}");

        string rawApiKey = "";
        using (var doc = JsonDocument.Parse(apiKeyGenJson))
        {
            if (doc.RootElement.TryGetProperty("data", out var dataElem) && dataElem.TryGetProperty("rawKey", out var rawKeyElem))
            {
                rawApiKey = rawKeyElem.GetString() ?? "";
            }
        }

        if (!string.IsNullOrEmpty(rawApiKey))
        {
            Console.WriteLine($"--> SUCCESS: Generated API Key: {rawApiKey}");
            Console.WriteLine($"\n5. Testing Protected Endpoint (/api/v1/Organizations) with x-api-key header...");
            using var apiKeyReq = new HttpRequestMessage(HttpMethod.Get, "/api/v1/Organizations");
            apiKeyReq.Headers.Add("x-api-key", rawApiKey);
            var apiKeyResp = await client.SendAsync(apiKeyReq);
            Console.WriteLine($"ApiKey Auth Status: {apiKeyResp.StatusCode}");
            Console.WriteLine($"ApiKey Auth Response: {await apiKeyResp.Content.ReadAsStringAsync()}");
        }

        Console.WriteLine("\n==================================================");
        Console.WriteLine("        ALL AUTHENTICATION TESTS COMPLETED        ");
        Console.WriteLine("==================================================");
    }
}
