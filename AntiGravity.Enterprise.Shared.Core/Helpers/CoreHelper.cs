using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Xml;
using System.Xml.Linq;
using Dapper;
using Newtonsoft.Json;
using SkiaSharp;

namespace AntiGravity.Enterprise.Shared.Core.Helpers
{
    public static class CoreHelper
    {
        #region Database & ID Generator Helpers

        /// <summary>
        /// Generates a unique business ID or primary key using the MySQL stored procedure `pr_getid`.
        /// </summary>
        /// <param name="connection">Active IDbConnection (MySQL / Dapper-compatible).</param>
        /// <param name="companyId">Company / Tenant ID (PNF_CID).</param>
        /// <param name="keyType">Key type identifier (e.g. TRNID, USRID, CNTID, AREAID, PROID, TKNAREAID, TESTTKN, TKNID).</param>
        /// <param name="subKey">Optional foreign / parent key prefix (PFKEY).</param>
        /// <param name="transaction">Optional IDbTransaction context.</param>
        /// <returns>Generated unique ID string.</returns>
        public static async Task<string> GenerateIdAsync(
            IDbConnection connection, 
            int companyId, 
            string keyType, 
            string subKey = "0", 
            IDbTransaction? transaction = null)
        {
            if (connection == null)
                throw new ArgumentNullException(nameof(connection));

            var parameters = new DynamicParameters();
            parameters.Add("PNF_CID", companyId, DbType.Int32, ParameterDirection.Input);
            parameters.Add("PKEY", keyType, DbType.String, ParameterDirection.Input, 20);
            parameters.Add("PFKEY", subKey, DbType.String, ParameterDirection.Input, 20);
            parameters.Add("PRTABLE", 0, DbType.SByte, ParameterDirection.Input);
            parameters.Add("OID", dbType: DbType.String, direction: ParameterDirection.Output, size: 30);

            await connection.ExecuteAsync(
                "pr_getid", 
                parameters, 
                transaction: transaction, 
                commandType: CommandType.StoredProcedure);

            var generatedId = parameters.Get<string>("OID");
            return generatedId ?? "0";
        }

        #endregion

        #region JSON & XML Conversion Helpers

        /// <summary>
        /// Converts a JSON string into an XML string.
        /// </summary>
        /// <param name="json">JSON input string.</param>
        /// <param name="rootElementName">Root XML element name (default: "Root").</param>
        /// <param name="writeArrayAttribute">Whether to write json:Array attribute on array elements.</param>
        /// <returns>Formatted XML string.</returns>
        public static string JsonToXml(string? json, string rootElementName = "Root", bool writeArrayAttribute = false)
        {
            if (string.IsNullOrWhiteSpace(json)) return string.Empty;

            XmlDocument? doc;
            if (json.TrimStart().StartsWith("["))
            {
                // Root is a JSON array
                doc = JsonConvert.DeserializeXmlNode($"{{\"{rootElementName}\": {json}}}");
            }
            else
            {
                // Root is a JSON object
                doc = JsonConvert.DeserializeXmlNode(json, rootElementName, writeArrayAttribute);
            }

            if (doc == null) return string.Empty;

            using var stringWriter = new StringWriter();
            using var xmlWriter = XmlWriter.Create(stringWriter, new XmlWriterSettings { Indent = true, OmitXmlDeclaration = true });
            doc.WriteTo(xmlWriter);
            xmlWriter.Flush();
            return stringWriter.ToString();
        }

        /// <summary>
        /// Converts an XML string into a JSON string.
        /// </summary>
        /// <param name="xml">XML input string.</param>
        /// <param name="omitRootObject">Whether to omit the outer root node in the JSON output.</param>
        /// <param name="indent">Format JSON with line breaks and indentation.</param>
        /// <returns>JSON string.</returns>
        public static string XmlToJson(string? xml, bool omitRootObject = false, bool indent = true)
        {
            if (string.IsNullOrWhiteSpace(xml)) return string.Empty;

            var doc = new XmlDocument();
            doc.LoadXml(xml);

            Newtonsoft.Json.Formatting formatting = indent ? Newtonsoft.Json.Formatting.Indented : Newtonsoft.Json.Formatting.None;
            return JsonConvert.SerializeXmlNode(doc, formatting, omitRootObject);
        }

        /// <summary>
        /// Converts a C# object to an XML string using XmlSerializer.
        /// </summary>
        /// <typeparam name="T">Type of object.</typeparam>
        /// <param name="obj">Object instance.</param>
        /// <param name="omitXmlDeclaration">Whether to omit the <?xml version="1.0"?> header (default true).</param>
        /// <returns>XML string.</returns>
        public static string ObjectToXml<T>(T obj, bool omitXmlDeclaration = true)
        {
            if (obj == null) return string.Empty;

            var serializer = new System.Xml.Serialization.XmlSerializer(typeof(T));
            var settings = new XmlWriterSettings
            {
                Indent = true,
                OmitXmlDeclaration = omitXmlDeclaration,
                Encoding = Encoding.UTF8
            };

            var namespaces = new System.Xml.Serialization.XmlSerializerNamespaces();
            namespaces.Add(string.Empty, string.Empty); // Remove default xmlns namespaces for clean XML

            using var stringWriter = new StringWriter();
            using var xmlWriter = XmlWriter.Create(stringWriter, settings);
            serializer.Serialize(xmlWriter, obj, namespaces);
            return stringWriter.ToString();
        }

        /// <summary>
        /// Deserializes an XML string back into a strongly-typed C# object instance.
        /// </summary>
        /// <typeparam name="T">Target object type.</typeparam>
        /// <param name="xml">XML string content.</param>
        /// <returns>Deserialized object instance (or default if XML is empty).</returns>
        public static T? XmlToObject<T>(string? xml)
        {
            if (string.IsNullOrWhiteSpace(xml)) return default;

            var serializer = new System.Xml.Serialization.XmlSerializer(typeof(T));
            using var stringReader = new StringReader(xml);
            return (T?)serializer.Deserialize(stringReader);
        }

        /// <summary>
        /// Converts a JSON string into a YAML string.
        /// </summary>
        /// <param name="json">JSON input string.</param>
        /// <returns>YAML string.</returns>
        public static string JsonToYaml(string? json)
        {
            if (string.IsNullOrWhiteSpace(json)) return string.Empty;

            var deserializer = new YamlDotNet.Serialization.DeserializerBuilder()
                .WithAttemptingUnquotedStringTypeDeserialization()
                .Build();

            var serializer = new YamlDotNet.Serialization.SerializerBuilder()
                .JsonCompatible()
                .Build();

            // First deserialize JSON object to generic dynamic model
            using var reader = new StringReader(json);
            var obj = new YamlDotNet.Serialization.DeserializerBuilder().Build().Deserialize(reader);

            var yamlSerializer = new YamlDotNet.Serialization.SerializerBuilder().Build();
            return yamlSerializer.Serialize(obj);
        }

        /// <summary>
        /// Converts a YAML string into a JSON string.
        /// </summary>
        /// <param name="yaml">YAML input string.</param>
        /// <param name="indent">Format JSON with indentation.</param>
        /// <returns>JSON string.</returns>
        public static string YamlToJson(string? yaml, bool indent = true)
        {
            if (string.IsNullOrWhiteSpace(yaml)) return "{}";

            var deserializer = new YamlDotNet.Serialization.DeserializerBuilder().Build();
            using var reader = new StringReader(yaml);
            var yamlObject = deserializer.Deserialize(reader);

            Newtonsoft.Json.Formatting formatting = indent ? Newtonsoft.Json.Formatting.Indented : Newtonsoft.Json.Formatting.None;
            return JsonConvert.SerializeObject(yamlObject, formatting);
        }

        /// <summary>
        /// Serializes a C# object instance directly into a YAML string.
        /// </summary>
        /// <typeparam name="T">Object type.</typeparam>
        /// <param name="obj">Object instance.</param>
        /// <returns>YAML string.</returns>
        public static string ObjectToYaml<T>(T obj)
        {
            if (obj == null) return string.Empty;

            var serializer = new YamlDotNet.Serialization.SerializerBuilder().Build();
            return serializer.Serialize(obj);
        }

        /// <summary>
        /// Deserializes a YAML string directly into a strongly-typed C# object instance.
        /// </summary>
        /// <typeparam name="T">Target object type.</typeparam>
        /// <param name="yaml">YAML string content.</param>
        /// <returns>Deserialized object instance.</returns>
        public static T? YamlToObject<T>(string? yaml)
        {
            if (string.IsNullOrWhiteSpace(yaml)) return default;

            var deserializer = new YamlDotNet.Serialization.DeserializerBuilder()
                .IgnoreUnmatchedProperties()
                .Build();

            using var reader = new StringReader(yaml);
            return deserializer.Deserialize<T>(reader);
        }

        /// <summary>
        /// Converts a JSON string (representing an array of objects) to a CSV string.
        /// </summary>
        /// <param name="json">JSON array string.</param>
        /// <param name="delimiter">CSV delimiter (default comma ',').</param>
        /// <returns>CSV string.</returns>
        public static string JsonToCsv(string? json, string delimiter = ",")
        {
            if (string.IsNullOrWhiteSpace(json)) return string.Empty;

            var jToken = Newtonsoft.Json.Linq.JToken.Parse(json);
            Newtonsoft.Json.Linq.JArray jArray = jToken is Newtonsoft.Json.Linq.JArray arr 
                ? arr 
                : new Newtonsoft.Json.Linq.JArray { jToken };

            if (!jArray.Any()) return string.Empty;

            var headers = jArray.OfType<Newtonsoft.Json.Linq.JObject>()
                .SelectMany(obj => obj.Properties().Select(p => p.Name))
                .Distinct()
                .ToList();

            var sb = new StringBuilder();
            sb.AppendLine(string.Join(delimiter, headers.Select(EscapeCsvField)));

            foreach (var item in jArray.OfType<Newtonsoft.Json.Linq.JObject>())
            {
                var line = headers.Select(header =>
                {
                    var val = item[header]?.ToString() ?? string.Empty;
                    return EscapeCsvField(val);
                });
                sb.AppendLine(string.Join(delimiter, line));
            }

            return sb.ToString();
        }

        /// <summary>
        /// Converts a CSV string into a JSON array string.
        /// </summary>
        /// <param name="csv">CSV string content.</param>
        /// <param name="delimiter">CSV delimiter (default comma ',').</param>
        /// <param name="indent">Format JSON output with indentation.</param>
        /// <returns>JSON string.</returns>
        public static string CsvToJson(string? csv, char delimiter = ',', bool indent = true)
        {
            if (string.IsNullOrWhiteSpace(csv)) return "[]";

            var lines = ReadCsvLines(csv, delimiter);
            if (!lines.Any()) return "[]";

            var headers = lines[0];
            var resultList = new List<Dictionary<string, string>>();

            for (int i = 1; i < lines.Count; i++)
            {
                var row = lines[i];
                var dict = new Dictionary<string, string>();
                for (int j = 0; j < headers.Count; j++)
                {
                    string key = headers[j];
                    string value = j < row.Count ? row[j] : string.Empty;
                    dict[key] = value;
                }
                resultList.Add(dict);
            }

            Newtonsoft.Json.Formatting formatting = indent ? Newtonsoft.Json.Formatting.Indented : Newtonsoft.Json.Formatting.None;
            return JsonConvert.SerializeObject(resultList, formatting);
        }

        /// <summary>
        /// Converts a C# IEnumerable of objects to CSV format.
        /// </summary>
        public static string ListToCsv<T>(IEnumerable<T>? list, string delimiter = ",")
        {
            if (list == null || !list.Any()) return string.Empty;
            string json = JsonConvert.SerializeObject(list);
            return JsonToCsv(json, delimiter);
        }

        /// <summary>
        /// Converts a CSV string into a strongly-typed List of C# objects.
        /// </summary>
        public static List<T> CsvToList<T>(string? csv, char delimiter = ',')
        {
            if (string.IsNullOrWhiteSpace(csv)) return new List<T>();
            string json = CsvToJson(csv, delimiter, indent: false);
            return JsonConvert.DeserializeObject<List<T>>(json) ?? new List<T>();
        }

        private static string EscapeCsvField(string field)
        {
            if (string.IsNullOrEmpty(field)) return "\"\"";
            if (field.Contains(",") || field.Contains("\"") || field.Contains("\n") || field.Contains("\r"))
            {
                return $"\"{field.Replace("\"", "\"\"")}\"";
            }
            return field;
        }

        private static List<List<string>> ReadCsvLines(string csvText, char delimiter)
        {
            var result = new List<List<string>>();
            using var reader = new StringReader(csvText);
            string? line;
            while ((line = reader.ReadLine()) != null)
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                var row = new List<string>();
                bool inQuotes = false;
                var sb = new StringBuilder();

                for (int i = 0; i < line.Length; i++)
                {
                    char c = line[i];
                    if (c == '"')
                    {
                        if (inQuotes && i + 1 < line.Length && line[i + 1] == '"')
                        {
                            sb.Append('"');
                            i++;
                        }
                        else
                        {
                            inQuotes = !inQuotes;
                        }
                    }
                    else if (c == delimiter && !inQuotes)
                    {
                        row.Add(sb.ToString());
                        sb.Clear();
                    }
                    else
                    {
                        sb.Append(c);
                    }
                }
                row.Add(sb.ToString());
                result.Add(row);
            }
            return result;
        }

        #endregion

        #region Base64 Encoding / Decoding

        /// <summary>
        /// Encodes plain text string to Base64 format.
        /// </summary>
        public static string Base64Encode(string? plainText, Encoding? encoding = null)
        {
            if (string.IsNullOrEmpty(plainText)) return string.Empty;
            encoding ??= Encoding.UTF8;
            byte[] bytes = encoding.GetBytes(plainText);
            return Convert.ToBase64String(bytes);
        }

        /// <summary>
        /// Decodes a Base64 string back to plain text.
        /// </summary>
        public static string Base64Decode(string? base64EncodedData, Encoding? encoding = null)
        {
            if (string.IsNullOrEmpty(base64EncodedData)) return string.Empty;
            encoding ??= Encoding.UTF8;
            byte[] bytes = Convert.FromBase64String(base64EncodedData);
            return encoding.GetString(bytes);
        }

        /// <summary>
        /// Encodes byte array to Base64 string.
        /// </summary>
        public static string Base64EncodeBytes(byte[]? data)
        {
            if (data == null || data.Length == 0) return string.Empty;
            return Convert.ToBase64String(data);
        }

        /// <summary>
        /// Decodes Base64 string to byte array.
        /// </summary>
        public static byte[] Base64DecodeBytes(string? base64EncodedData)
        {
            if (string.IsNullOrEmpty(base64EncodedData)) return Array.Empty<byte>();
            return Convert.FromBase64String(base64EncodedData);
        }

        /// <summary>
        /// Encodes plain text string to URL-safe Base64 format (RFC 4648) replacing '+' with '-', '/' with '_', and trimming padding '='.
        /// Safe for use in URL query parameters, JWT tokens, and REST paths.
        /// </summary>
        public static string Base64UrlEncode(string? plainText, Encoding? encoding = null)
        {
            if (string.IsNullOrEmpty(plainText)) return string.Empty;
            encoding ??= Encoding.UTF8;
            byte[] bytes = encoding.GetBytes(plainText);
            return Base64UrlEncodeBytes(bytes);
        }

        /// <summary>
        /// Encodes byte array to URL-safe Base64 format (RFC 4648).
        /// </summary>
        public static string Base64UrlEncodeBytes(byte[]? data)
        {
            if (data == null || data.Length == 0) return string.Empty;
            string base64 = Convert.ToBase64String(data);
            return base64.Replace('+', '-').Replace('/', '_').TrimEnd('=');
        }

        /// <summary>
        /// Decodes a URL-safe Base64 string back to plain text.
        /// </summary>
        public static string Base64UrlDecode(string? base64UrlString, Encoding? encoding = null)
        {
            if (string.IsNullOrEmpty(base64UrlString)) return string.Empty;
            encoding ??= Encoding.UTF8;
            byte[] bytes = Base64UrlDecodeBytes(base64UrlString);
            return encoding.GetString(bytes);
        }

        /// <summary>
        /// Decodes a URL-safe Base64 string back to a byte array.
        /// </summary>
        public static byte[] Base64UrlDecodeBytes(string? base64UrlString)
        {
            if (string.IsNullOrEmpty(base64UrlString)) return Array.Empty<byte>();

            string base64 = base64UrlString.Replace('-', '+').Replace('_', '/');
            switch (base64.Length % 4)
            {
                case 2: base64 += "=="; break;
                case 3: base64 += "="; break;
            }
            return Convert.FromBase64String(base64);
        }

        /// <summary>
        /// Encodes an image byte array to a Base64 string, optionally formatted as a Data URI (e.g. data:image/png;base64,...).
        /// </summary>
        /// <param name="imageBytes">Raw image byte array.</param>
        /// <param name="mimeType">Optional MIME type (e.g. "image/png", "image/jpeg"). If provided, formats as Data URI.</param>
        /// <returns>Base64 or Data URI string.</returns>
        public static string ImageToBase64(byte[]? imageBytes, string? mimeType = null)
        {
            if (imageBytes == null || imageBytes.Length == 0) return string.Empty;
            string base64 = Convert.ToBase64String(imageBytes);

            if (!string.IsNullOrWhiteSpace(mimeType))
            {
                string cleanMime = mimeType.StartsWith("data:") ? mimeType : $"data:{mimeType.TrimStart('.')};base64,";
                return $"{cleanMime}{base64}";
            }

            return base64;
        }

        /// <summary>
        /// Reads an image file from disk and encodes it to a Base64 string or Data URI.
        /// </summary>
        public static string ImageFileToBase64(string filePath, bool asDataUri = true)
        {
            if (!File.Exists(filePath))
                throw new FileNotFoundException("Image file not found.", filePath);

            byte[] bytes = File.ReadAllBytes(filePath);

            if (asDataUri)
            {
                string extension = Path.GetExtension(filePath).TrimStart('.').ToLower();
                string mimeType = extension switch
                {
                    "png" => "image/png",
                    "jpg" or "jpeg" => "image/jpeg",
                    "gif" => "image/gif",
                    "webp" => "image/webp",
                    "svg" => "image/svg+xml",
                    _ => "image/png"
                };
                return ImageToBase64(bytes, mimeType);
            }

            return ImageToBase64(bytes);
        }

        /// <summary>
        /// Decodes a Base64 string or Data URI (e.g., "data:image/png;base64,...") back into a raw image byte array.
        /// </summary>
        public static byte[] Base64ToImageBytes(string? base64String)
        {
            if (string.IsNullOrWhiteSpace(base64String)) return Array.Empty<byte>();

            string cleanBase64 = base64String;
            int dataUriIndex = base64String.IndexOf(";base64,", StringComparison.OrdinalIgnoreCase);
            if (dataUriIndex >= 0)
            {
                cleanBase64 = base64String.Substring(dataUriIndex + 8);
            }

            return Convert.FromBase64String(cleanBase64.Trim());
        }

        /// <summary>
        /// Decodes a Base64 string or Data URI and saves it as an image file on disk.
        /// </summary>
        public static void Base64ToImageFile(string base64String, string destinationFilePath)
        {
            byte[] bytes = Base64ToImageBytes(base64String);
            File.WriteAllBytes(destinationFilePath, bytes);
        }

        #endregion

        #region Color Conversion Helpers (RGB <-> HEX)

        /// <summary>
        /// Represents RGB (and optional Alpha) color values.
        /// </summary>
        public class RgbColorResult
        {
            public byte R { get; set; }
            public byte G { get; set; }
            public byte B { get; set; }
            public byte A { get; set; } = 255;

            public override string ToString()
            {
                return A == 255 ? $"rgb({R}, {G}, {B})" : $"rgba({R}, {G}, {B}, {Math.Round(A / 255.0, 2)})";
            }
        }

        /// <summary>
        /// Converts Red, Green, Blue (and optional Alpha) byte values into a HEX color string (e.g. #FF5733 or #FF5733FF).
        /// </summary>
        /// <param name="r">Red component (0-255).</param>
        /// <param name="g">Green component (0-255).</param>
        /// <param name="b">Blue component (0-255).</param>
        /// <param name="a">Optional Alpha component (0-255, default null / 255).</param>
        /// <param name="includeHash">Include leading '#' prefix (default true).</param>
        /// <returns>Hex color string.</returns>
        public static string RgbToHex(byte r, byte g, byte b, byte? a = null, bool includeHash = true)
        {
            string prefix = includeHash ? "#" : string.Empty;
            if (a.HasValue && a.Value < 255)
            {
                return $"{prefix}{r:X2}{g:X2}{b:X2}{a.Value:X2}";
            }
            return $"{prefix}{r:X2}{g:X2}{b:X2}";
        }

        /// <summary>
        /// Converts a HEX color string (e.g., "#FF5733", "FF5733", "#F57", or "#FF573380") into an RgbColorResult model.
        /// </summary>
        /// <param name="hex">Hex color string.</param>
        /// <returns>RgbColorResult instance containing R, G, B, and A values.</returns>
        public static RgbColorResult HexToRgb(string? hex)
        {
            if (string.IsNullOrWhiteSpace(hex))
                throw new ArgumentException("Hex color string cannot be null or empty.", nameof(hex));

            string cleanHex = hex.Trim().TrimStart('#');

            // Handle shorthand hex like #F57 -> #FF5577
            if (cleanHex.Length == 3 || cleanHex.Length == 4)
            {
                cleanHex = string.Concat(cleanHex.Select(c => $"{c}{c}"));
            }

            if (cleanHex.Length != 6 && cleanHex.Length != 8)
                throw new FormatException($"Invalid HEX color format '{hex}'. Expected 3, 4, 6, or 8 characters.");

            byte r = Convert.ToByte(cleanHex.Substring(0, 2), 16);
            byte g = Convert.ToByte(cleanHex.Substring(2, 2), 16);
            byte b = Convert.ToByte(cleanHex.Substring(4, 2), 16);
            byte a = cleanHex.Length == 8 ? Convert.ToByte(cleanHex.Substring(6, 2), 16) : (byte)255;

            return new RgbColorResult { R = r, G = g, B = b, A = a };
        }

        #endregion

        #region String & HTML Encoding Helpers

        /// <summary>
        /// Encodes a string for safe inclusion in a URL.
        /// </summary>
        public static string UrlEncode(string? input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            return HttpUtility.UrlEncode(input);
        }

        /// <summary>
        /// Decodes a URL-encoded string back to its original representation.
        /// </summary>
        public static string UrlDecode(string? input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            return HttpUtility.UrlDecode(input);
        }

        /// <summary>
        /// Encodes a string for safe HTML rendering to prevent XSS attacks.
        /// </summary>
        public static string HtmlEncode(string? input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            return HttpUtility.HtmlEncode(input);
        }

        /// <summary>
        /// Decodes an HTML-encoded string.
        /// </summary>
        public static string HtmlDecode(string? input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            return HttpUtility.HtmlDecode(input);
        }

        /// <summary>
        /// Represents a parsed URL broken down into components and query parameters.
        /// </summary>
        public class UrlParseResult
        {
            public string OriginalUrl { get; set; } = string.Empty;
            public string Scheme { get; set; } = string.Empty;       // http, https
            public string Host { get; set; } = string.Empty;         // api.example.com
            public int Port { get; set; }                           // 80, 443, 5026
            public string Path { get; set; } = string.Empty;         // /v1/users
            public string QueryString { get; set; } = string.Empty;  // ?page=1&sort=desc
            public string Fragment { get; set; } = string.Empty;     // #section1
            public Dictionary<string, string> QueryParameters { get; set; } = new(StringComparer.OrdinalIgnoreCase);

            /// <summary>
            /// Gets a query parameter value by key name.
            /// </summary>
            public string? GetQueryParam(string key)
            {
                return QueryParameters.TryGetValue(key, out var val) ? val : null;
            }
        }

        /// <summary>
        /// Parses any absolute or relative URL string into a UrlParseResult object with parsed Query Parameters.
        /// </summary>
        /// <param name="url">URL string to parse.</param>
        /// <returns>UrlParseResult model.</returns>
        public static UrlParseResult ParseUrl(string? url)
        {
            if (string.IsNullOrWhiteSpace(url))
                return new UrlParseResult();

            string targetUrl = url.Trim();
            // Handle relative URLs by prepending dummy scheme for Uri parsing
            bool isRelative = !Uri.IsWellFormedUriString(targetUrl, UriKind.Absolute);
            Uri uri = isRelative ? new Uri("http://dummy.local" + (targetUrl.StartsWith("/") ? "" : "/") + targetUrl) : new Uri(targetUrl);

            var result = new UrlParseResult
            {
                OriginalUrl = url,
                Scheme = isRelative ? string.Empty : uri.Scheme,
                Host = isRelative ? string.Empty : uri.Host,
                Port = isRelative ? 0 : uri.Port,
                Path = uri.AbsolutePath,
                QueryString = uri.Query,
                Fragment = uri.Fragment
            };

            if (!string.IsNullOrEmpty(uri.Query))
            {
                var queryCollection = HttpUtility.ParseQueryString(uri.Query);
                foreach (string? key in queryCollection.AllKeys)
                {
                    if (key != null)
                    {
                        result.QueryParameters[key] = queryCollection[key] ?? string.Empty;
                    }
                }
            }

            return result;
        }

        #endregion

        #region Age & Date Calculation

        /// <summary>
        /// Represents calculated age broken down into Years, Months, and Days.
        /// </summary>
        public class AgeResult
        {
            public int Years { get; set; }
            public int Months { get; set; }
            public int Days { get; set; }

            public override string ToString()
            {
                return $"{Years} Year(s), {Months} Month(s), {Days} Day(s)";
            }
        }

        /// <summary>
        /// Calculates exact age in Years, Months, and Days from a birth date up to an optional target date (defaults to today).
        /// </summary>
        /// <param name="birthDate">The date of birth.</param>
        /// <param name="targetDate">Optional reference date (defaults to DateTime.Today).</param>
        /// <returns>AgeResult model containing Years, Months, and Days.</returns>
        public static AgeResult CalculateAge(DateTime birthDate, DateTime? targetDate = null)
        {
            DateTime endDate = targetDate?.Date ?? DateTime.Today;
            DateTime startDate = birthDate.Date;

            if (startDate > endDate)
            {
                return new AgeResult { Years = 0, Months = 0, Days = 0 };
            }

            int years = endDate.Year - startDate.Year;
            int months = endDate.Month - startDate.Month;
            int days = endDate.Day - startDate.Day;

            if (days < 0)
            {
                months--;
                var previousMonth = endDate.AddMonths(-1);
                days += DateTime.DaysInMonth(previousMonth.Year, previousMonth.Month);
            }

            if (months < 0)
            {
                years--;
                months += 12;
            }

            return new AgeResult
            {
                Years = years,
                Months = months,
                Days = days
            };
        }

        #endregion

        #region Image Resizing Helpers (SkiaSharp - Cross Platform & Open Source)

        /// <summary>
        /// Resizes an image byte array to specified maximum width and height while maintaining aspect ratio.
        /// </summary>
        /// <param name="imageBytes">Original image byte array.</param>
        /// <param name="maxWidth">Maximum target width in pixels.</param>
        /// <param name="maxHeight">Maximum target height in pixels.</param>
        /// <param name="format">Encoded image output format (JPEG by default).</param>
        /// <param name="quality">Quality (1-100, default 85).</param>
        /// <returns>Resized image byte array.</returns>
        public static byte[] ResizeImage(byte[] imageBytes, int maxWidth, int maxHeight, SKEncodedImageFormat format = SKEncodedImageFormat.Jpeg, int quality = 85)
        {
            if (imageBytes == null || imageBytes.Length == 0)
                throw new ArgumentNullException(nameof(imageBytes));

            using var originalBitmap = SKBitmap.Decode(imageBytes);
            if (originalBitmap == null)
                throw new InvalidOperationException("Could not decode image bytes.");

            float ratioX = (float)maxWidth / originalBitmap.Width;
            float ratioY = (float)maxHeight / originalBitmap.Height;
            float ratio = Math.Min(ratioX, ratioY);

            int newWidth = (int)(originalBitmap.Width * ratio);
            int newHeight = (int)(originalBitmap.Height * ratio);

            using var resizedBitmap = originalBitmap.Resize(new SKImageInfo(newWidth, newHeight), SKFilterQuality.High);
            using var image = SKImage.FromBitmap(resizedBitmap);
            using var data = image.Encode(format, quality);

            return data.ToArray();
        }

        /// <summary>
        /// Resizes an image file on disk and saves the resulting image to a destination path.
        /// </summary>
        public static void ResizeImageFile(string sourceFilePath, string destinationFilePath, int maxWidth, int maxHeight, SKEncodedImageFormat format = SKEncodedImageFormat.Jpeg, int quality = 85)
        {
            byte[] inputBytes = File.ReadAllBytes(sourceFilePath);
            byte[] outputBytes = ResizeImage(inputBytes, maxWidth, maxHeight, format, quality);
            File.WriteAllBytes(destinationFilePath, outputBytes);
        }

        #endregion

        #region Enum Helpers

        /// <summary>
        /// Represents an Enum item transformed into a key-value list model.
        /// </summary>
        public class EnumItemModel
        {
            public int Value { get; set; }
            public string Name { get; set; } = string.Empty;
            public string Description { get; set; } = string.Empty;
        }

        /// <summary>
        /// Converts any C# Enum into a list of EnumItemModel (value, name, description).
        /// </summary>
        /// <typeparam name="TEnum">Enum type.</typeparam>
        public static List<EnumItemModel> EnumToList<TEnum>() where TEnum : Enum
        {
            var list = new List<EnumItemModel>();
            var enumType = typeof(TEnum);

            foreach (TEnum val in Enum.GetValues(enumType))
            {
                var field = enumType.GetField(val.ToString());
                var description = field?.GetCustomAttribute<DescriptionAttribute>()?.Description ?? val.ToString();

                list.Add(new EnumItemModel
                {
                    Value = Convert.ToInt32(val),
                    Name = val.ToString(),
                    Description = description
                });
            }

            return list;
        }

        #endregion
    }
}
