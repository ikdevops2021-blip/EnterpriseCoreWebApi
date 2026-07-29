-- NexusCore Seed Data (MySQL Version with 1,000-Item Parameter ID Range Strategy)

-- 1. Clean existing seed data
DELETE FROM `SystemConfigurationKeys` WHERE `Key` IN (
    'App.Name',
    'App.Logging.EnableDebugLog',
    'App.Logging.LogLevel',
    'App.MaintenanceMode',
    'Security.RequireOrganizationHeader',
    'Security.ApiKeyPrefix',
    'Integration.DefaultAuditLevel',
    'Integration.EnableLogging'
);

DELETE FROM `ConfigParameters` WHERE `CategoryID` IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17);

DELETE FROM `ConfigCategory` WHERE `CategoryID` IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17);

-- 2. Insert Categories (Explicit CategoryIDs 1..15)
INSERT INTO `ConfigCategory` (
    `CategoryID`, `CategoryCode`, `CategoryName`, `Description`, `Priority`, `Active`, `AllowModify`,
    `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`
) VALUES
(1,  'GEN',        'C_GENDER',           'Gender and sex identification parameters.', 1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2,  'TITLE',      'C_TITLE',            'Name salutation titles.', 2, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3,  'BLD',        'C_BLOODGROUP',       'Human blood group classifications.', 3, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(4,  'ADRTYPE',    'C_ADDRESSTYPE',      'Physical and billing address type categories.', 4, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(5,  'CNTTYPE',    'C_CONTACTTYPE',      'Communication channel and contact method types.', 5, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6,  'UNITTYPE',   'C_UNITTYPE',         'Measurement and quantity unit parameters.', 6, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(7,  'MARITAL',    'C_MARITALSTATUS',    'Marital and civil status options.', 7, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(8,  'DOCTYPE',    'C_DOCUMENTTYPE',     'Verification and identification document types.', 8, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9,  'CURRENCY',   'C_CURRENCY',         'Global transaction currencies.', 9, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(10, 'PRIORITY',   'C_PRIORITYLEVEL',    'Task, ticket, and audit priority levels.', 10, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(11, 'SEVERITY',   'C_SEVERITY',         'Defect, incident, and risk severity levels.', 11, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(12, 'NOTIFTYPE',  'C_NOTIFICATIONTYPE', 'Notification delivery channel preferences.', 12, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13, 'LANG',       'C_LANGUAGE',         'Supported locale and interface languages.', 13, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14, 'PAYMENT',    'C_PAYMENTMETHOD',    'Payment and transaction processing methods.', 14, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15, 'DATA_TYPE',  'C_DATATYPE',         'Supported data types for system configuration.', 15, 1, 0, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16, 'RELATION',   'C_RELATIONSHIP',     'Family, personal, and dependent relationships.', 16, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(17, 'NOTIF_EVT',  'C_NOTIFICATION_EVENT', 'Master list of notification event codes and intimations.', 17, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0);

-- 3. Insert Parameters with 1,000-Item Incremental Ranges
INSERT INTO `ConfigParameters` (
    `ParameterID`, `CategoryID`, `ParameterCode`, `ParameterName`, `Priority`, `IsDefault`, `IsActive`,
    `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`
) VALUES
-- Category 1: C_GENDER (Range: 1001-1999)
(1001, 1, 'M',   'Male',               1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(1002, 1, 'F',   'Female',             2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(1003, 1, 'TGM', 'Transgender Male',   3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(1004, 1, 'TGF', 'Transgender Female', 4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(1005, 1, 'UN',  'Unknown',            5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 2: C_TITLE (Range: 2001-2999)
(2001, 2, 'Sir',     'Sir',      1, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2002, 2, 'Madam',   'Madam',    2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2003, 2, 'Mr.',     'Mr.',      3, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2004, 2, 'Ms.',     'Ms.',      4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2005, 2, 'Mrs.',    'Mrs.',     5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2006, 2, 'Miss',    'Miss',     6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2007, 2, 'Dr.',     'Dr.',      7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2008, 2, 'Doctor',  'Doctor',   8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(2009, 2, 'Prof',    'Profesor', 9, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 3: C_BLOODGROUP (Range: 3001-3999)
(3001, 3, 'O_POS',  'O+',  1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3002, 3, 'O_NEG',  'O-',  2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3003, 3, 'A_POS',  'A+',  3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3004, 3, 'A_NEG',  'A-',  4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3005, 3, 'B_POS',  'B+',  5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3006, 3, 'B_NEG',  'B-',  6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3007, 3, 'AB_POS', 'AB+', 7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(3008, 3, 'AB_NEG', 'AB-', 8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 4: C_ADDRESSTYPE (Range: 4001-4999)
(4001, 4, 'RESIDENTIAL', 'Residential Address', 1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(4002, 4, 'PERMANENT',   'Permanent Address',   2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(4003, 4, 'WORK',        'Office / Work',       3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(4004, 4, 'BILLING',     'Billing Address',     4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(4005, 4, 'SHIPPING',    'Shipping Address',    5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 5: C_CONTACTTYPE (Range: 5001-5999)
(5001, 5, 'MOBILE',      'Mobile Phone',        1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(5002, 5, 'WORK_PHONE',  'Work Landline',       2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(5003, 5, 'EMAIL_PERS',  'Personal Email',      3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(5004, 5, 'EMAIL_WORK',  'Work Email',          4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(5005, 5, 'WHATSAPP',    'WhatsApp',            5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(5006, 5, 'FAX',         'Fax',                 6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 6: C_UNITTYPE (Range: 6001-6999)
(6001, 6, 'PCS',  'Pieces (pcs)',           1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6002, 6, 'KG',   'Kilograms (kg)',         2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6003, 6, 'G',    'Grams (g)',              3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6004, 6, 'MG',   'Milligrams (mg)',        4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6005, 6, 'LB',   'Pounds (lbs)',           5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6006, 6, 'OZ',   'Ounces (oz)',            6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6007, 6, 'L',    'Liters (L)',             7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6008, 6, 'ML',   'Milliliters (mL)',       8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6009, 6, 'M',    'Meters (m)',             9, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6010, 6, 'CM',   'Centimeters (cm)',      10, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6011, 6, 'MM',   'Millimeters (mm)',      11, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6012, 6, 'KM',   'Kilometers (km)',       12, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6013, 6, 'IN',   'Inches (in)',           13, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6014, 6, 'FT',   'Feet (ft)',             14, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6015, 6, 'SQM',  'Square Meters (m²)',    15, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6016, 6, 'SQFT', 'Square Feet (sq ft)',   16, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6017, 6, 'HRS',  'Hours (hrs)',           17, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6018, 6, 'MIN',  'Minutes (min)',         18, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6019, 6, 'SEC',  'Seconds (sec)',         19, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6020, 6, 'DAY',  'Days (days)',           20, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6021, 6, 'BOX',  'Box (box)',             21, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6022, 6, 'PKT',  'Packet (pkt)',          22, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(6023, 6, 'SET',  'Set (set)',             23, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 7: C_MARITALSTATUS (Range: 7001-7999)
(7001, 7, 'SINGLE',   'Single',   1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(7002, 7, 'MARRIED',  'Married',  2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(7003, 7, 'DIVORCED', 'Divorced', 3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(7004, 7, 'WIDOWED',  'Widowed',  4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 8: C_DOCUMENTTYPE (Range: 8001-8999)
(8001, 8, 'PASSPORT', 'Passport',            1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(8002, 8, 'NAT_ID',   'National ID / SSN',   2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(8003, 8, 'DRV_LIC',  'Driving License',     3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(8004, 8, 'PAN_CARD', 'PAN Card',            4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(8005, 8, 'AADHAAR',  'Aadhaar Card',        5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(8006, 8, 'VOTER_ID', 'Voter ID',            6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(8007, 8, 'ABHA_CARD','ABHA Card',           7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 9: C_CURRENCY (Range: 9001-9999)
(9001, 9, 'USD', 'US Dollar ($)',           1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9002, 9, 'EUR', 'Euro (€)',                2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9003, 9, 'GBP', 'GB Pound Sterling (£)',   3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9004, 9, 'INR', 'Indian Rupee (₹)',        4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9005, 9, 'CAD', 'Canadian Dollar (CA$)',   5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9006, 9, 'AUD', 'Australian Dollar (A$)',  6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9007, 9, 'JPY', 'Japanese Yen (¥)',        7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9008, 9, 'CNY', 'Chinese Yuan (¥)',        8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9009, 9, 'CHF', 'Swiss Franc (CHF)',       9, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9010, 9, 'SGD', 'Singapore Dollar (S$)',  10, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9011, 9, 'AED', 'UAE Dirham (AED)',       11, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9012, 9, 'SAR', 'Saudi Riyal (SAR)',      12, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9013, 9, 'HKD', 'Hong Kong Dollar (HK$)', 13, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9014, 9, 'NZD', 'New Zealand Dollar (NZ$)',14, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9015, 9, 'MXN', 'Mexican Peso (MX$)',     15, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(9016, 9, 'BRL', 'Brazilian Real (R$)',    16, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 10: C_PRIORITYLEVEL (Range: 10001-10999)
(10001, 10, 'LOW',      'Low',      1, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(10002, 10, 'MEDIUM',   'Medium',   2, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(10003, 10, 'HIGH',     'High',     3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(10004, 10, 'CRITICAL', 'Critical', 4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 11: C_SEVERITY (Range: 11001-11999)
(11001, 11, 'MINOR',    'Minor',    1, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(11002, 11, 'MAJOR',    'Major',    2, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(11003, 11, 'CRITICAL', 'Critical', 3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 12: C_NOTIFICATIONTYPE (Range: 12001-12999)
(12001, 12, 'EMAIL',    'Email',       1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(12002, 12, 'SMS',      'SMS Text',    2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(12003, 12, 'IN_APP',   'In-App Push', 3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(12004, 12, 'WHATSAPP', 'WhatsApp',    4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 13: C_LANGUAGE (Range: 13001-13999)
(13001, 13, 'en',    'English',              1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13002, 13, 'es',    'Spanish (Español)',    2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13003, 13, 'fr',    'French (Français)',    3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13004, 13, 'de',    'German (Deutsch)',     4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13005, 13, 'zh-CN', 'Chinese Simplified (简体中文)', 5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13006, 13, 'zh-TW', 'Chinese Traditional (繁體中文)',6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13007, 13, 'ja',    'Japanese (日本語)',     7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13008, 13, 'ko',    'Korean (한국어)',        8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13009, 13, 'hi',    'Hindi (हिन्दी)',         9, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13010, 13, 'ar',    'Arabic (العربية)',      10, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13011, 13, 'pt',    'Portuguese (Português)',11, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13012, 13, 'ru',    'Russian (Русский)',     12, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13013, 13, 'it',    'Italian (Italiano)',    13, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13014, 13, 'nl',    'Dutch (Nederlands)',    14, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13015, 13, 'tr',    'Turkish (Türkçe)',      15, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13016, 13, 'pl',    'Polish (Polski)',       16, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13017, 13, 'sv',    'Swedish (Svenska)',     17, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13018, 13, 'da',    'Danish (Dansk)',        18, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13019, 13, 'fi',    'Finnish (Suomi)',       19, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13020, 13, 'no',    'Norwegian (Norsk)',     20, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13021, 13, 'cs',    'Czech (Čeština)',       21, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13022, 13, 'hu',    'Hungarian (Magyar)',    22, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13023, 13, 'ro',    'Romanian (Română)',     23, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13024, 13, 'el',    'Greek (Ελληνικά)',      24, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13025, 13, 'he',    'Hebrew (עברית)',        25, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13026, 13, 'th',    'Thai (ไทย)',            26, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13027, 13, 'id',    'Indonesian (Bahasa Indonesia)', 27, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13028, 13, 'vi',    'Vietnamese (Tiếng Việt)', 28, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13029, 13, 'bn',    'Bengali (বাংলা)',        29, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(13030, 13, 'uk',    'Ukrainian (Українська)', 30, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 14: C_PAYMENTMETHOD (Range: 14001-14999)
(14001, 14, 'CREDIT_CARD',  'Credit Card',            1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14002, 14, 'DEBIT_CARD',   'Debit Card',             2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14003, 14, 'BANK_XFER',    'Bank Transfer / ACH',    3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14004, 14, 'PAYPAL',       'PayPal',                 4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14005, 14, 'STRIPE',       'Stripe',                 5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14006, 14, 'APPLE_PAY',    'Apple Pay',              6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14007, 14, 'GOOGLE_PAY',   'Google Pay',             7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14008, 14, 'PAYTM',        'Paytm',                  8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14009, 14, 'PHONEPE',      'PhonePe',                9, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14010, 14, 'CRED',         'CRED Pay',              10, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14011, 14, 'CREDIT_LATER', 'Credit (Pay Later)',    11, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14012, 14, 'CASH',         'Cash on Delivery',      12, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(14013, 14, 'CHEQUE',       'Cheque / Draft',        13, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 15: C_DATATYPE (Range: 15001-15999)
(15001, 15, 'STRING',    'String / Text',     1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15002, 15, 'INT',       'Integer',           2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15003, 15, 'DECIMAL',   'Decimal / Float',   3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15004, 15, 'BOOL',      'Boolean (True/False)', 4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15005, 15, 'LONGTEXT',  'Long Text / HTML',  5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15006, 15, 'JSON',      'JSON Object/Array', 6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15007, 15, 'DATETIME',  'Date Time',         7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15008, 15, 'DATE',      'Date Only',         8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(15009, 15, 'GUID',      'Unique Identifier (GUID/UUID)', 9, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 16: C_RELATIONSHIP (Range: 16001-16999)
(16001, 16, 'SELF',        'Self',                1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16002, 16, 'FATHER',      'Father',              2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16003, 16, 'MOTHER',      'Mother',              3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16004, 16, 'SPOUSE',      'Spouse (Husband/Wife)',4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16005, 16, 'SON',         'Son',                 5, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16006, 16, 'DAUGHTER',    'Daughter',            6, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16007, 16, 'GUARDIAN',    'Legal Guardian',      7, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16008, 16, 'BROTHER',     'Brother',             8, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

-- Category 17: C_NOTIFICATION_EVENT (Range: 17001-17999)
(17001, 17, 'PAYMENT_RECEIVED',     'Payment Received',     1, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(17002, 17, 'INTERNAL_ANNOUNCEMENT','Internal Announcement',2, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(17003, 17, 'SYSTEM_ALERT',         'System & Security Alert', 3, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(17004, 17, 'APPROVAL_REQUESTED',   'Approval Request',     4, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),

(16009, 16, 'SISTER',      'Sister',              9, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16010, 16, 'GRANDFATHER', 'Grandfather',        10, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16011, 16, 'GRANDMOTHER', 'Grandmother',        11, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16012, 16, 'GRANDSON',    'Grandson',           12, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16013, 16, 'GRANDDAUGHTER','Granddaughter',     13, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16014, 16, 'UNCLE',       'Uncle',              14, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16015, 16, 'AUNT',        'Aunt',               15, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16016, 16, 'NEPHEW',      'Nephew',             16, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16017, 16, 'NIECE',       'Niece',              17, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16018, 16, 'COUSIN',      'Cousin',             18, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16019, 16, 'FATHER_IN_LAW','Father-in-Law',     19, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16020, 16, 'MOTHER_IN_LAW','Mother-in-Law',     20, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16021, 16, 'SON_IN_LAW',  'Son-in-Law',         21, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16022, 16, 'DAUGHTER_IN_LAW','Daughter-in-Law', 22, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16023, 16, 'FRIEND',      'Friend',             23, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
(16024, 16, 'OTHER',       'Other / Dependent',  24, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0);

-- 4. System Configuration Keys
INSERT INTO `SystemConfigurationKeys` (
    `Key`, `Value`, `Description`, `AcceptedValues`, `DataTypeID`, `AllowEdit`, `Active`,
    `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`
) VALUES
('App.Name', 'DNAQMSAPI', 'Application display name.', NULL, 15001, 0, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
('App.Logging.EnableDebugLog', '0', 'Enables or disables detailed debug/verbose application logging.', '0,1', 15004, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
('App.Logging.LogLevel', 'Information', 'Application minimum logging level threshold.', 'Verbose,Debug,Information,Warning,Error,Fatal', 15001, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
('App.MaintenanceMode', '0', 'Puts application into maintenance mode, blocking non-admin traffic.', '0,1', 15004, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
('Security.RequireOrganizationHeader', '1', 'Whether X-Organization-Id header is mandatory.', '0,1', 15004, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
('Security.ApiKeyPrefix', 'dnaqms_live_', 'Prefix used when generating API keys.', NULL, 15001, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
('Integration.DefaultAuditLevel', '1', 'Default audit level for integrations.', '0,1,2', 15002, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0),
('Integration.EnableLogging', '1', 'Enables integration request/response logging.', '0,1', 15004, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP, 0);
