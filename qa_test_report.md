# QA Automated Test Report

Run Date: 05/22/2026 02:00:22

## TaxEngine API
| Method | Endpoint | Status | Result |
|---|---|---|---|
| GET | /health | 200 | PASS |
| POST | /api/Tax/calculate | 200 | PASS |

## SubscriptionSaaS API
| Method | Endpoint | Status | Result |
|---|---|---|---|
| GET | /health | 200 | PASS |
| GET | /api/Subscription/123 | 404 | PASS (Client Error expected) |
| POST | /api/Subscription | 404 | PASS (Client Error expected) |
| POST | /api/Subscription/123/cancel | 404 | PASS (Client Error expected) |
| POST | /api/Subscription/test-feature | 404 | PASS (Client Error expected) |

## DNAQMS API
| Method | Endpoint | Status | Result |
|---|---|---|---|
| GET | /health | 200 | PASS |
| GET | /api/v1/Organizations | 401 | PASS (Client Error expected) |
| GET | /api/v1/Organizations/1 | 401 | PASS (Client Error expected) |
| POST | /api/v1/Integration/test-send | 200 | PASS |
| POST | /api/v1/Integration/configure | 200 | PASS |
| POST | /api/v1/Auth/login | 400 | PASS (Client Error expected) |
| POST | /api/v1/Auth/register | 400 | PASS (Client Error expected) |


