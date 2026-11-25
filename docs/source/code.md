# IP2Location Zig API

## Database

| Member | Description |
| --- | --- |
| `Database.open(io, path)` | Memory-maps a BIN file read-only. `deinit` closes it. |
| `db.deinit()` | Releases the mapping and closes the file. |
| `db.lookup(text)` | Looks up one address in IPv4 or IPv6 notation and returns a `Record`. Fails with the errors listed below. |
| `db.metadata()` | Returns the database type, column count, build date and row counts. |
| `db.supportsIpv4()` | Whether the file carries IPv4 ranges. |
| `db.supportsIpv6()` | Whether the file carries IPv6 ranges. |
| `record.get(field)` | Returns one field as `?Value`, for callers that choose fields at runtime. |

## Record fields

| Field Name | Type | Description |
| --- | --- | --- |
| `country_code` | `?[]const u8` | Two-character country code based on ISO 3166. |
| `country_name` | `?[]const u8` | Country name based on ISO 3166. |
| `region` | `?[]const u8` | Region or state name. |
| `city` | `?[]const u8` | City name. |
| `latitude` | `?f32` | City latitude. Defaults to capital city latitude if city is unknown. |
| `longitude` | `?f32` | City longitude. Defaults to capital city longitude if city is unknown. |
| `isp` | `?[]const u8` | Internet Service Provider or company's name. |
| `domain` | `?[]const u8` | Internet domain name associated with IP address range. |
| `zip_code` | `?[]const u8` | ZIP code or postal code. |
| `time_zone` | `?[]const u8` | UTC time zone, with daylight saving time applied. |
| `net_speed` | `?[]const u8` | Internet connection type. |
| `idd_code` | `?[]const u8` | The IDD prefix to call the city from another country. |
| `area_code` | `?[]const u8` | A varying length number assigned to geographic areas for calls between cities. |
| `weather_station_code` | `?[]const u8` | The special code to identify the nearest weather observation station. |
| `weather_station_name` | `?[]const u8` | The name of the nearest weather observation station. |
| `mcc` | `?[]const u8` | Mobile Country Code (MCC) as defined in ITU E.212. |
| `mnc` | `?[]const u8` | Mobile Network Code (MNC) used with the MCC to identify a mobile operator or carrier. |
| `mobile_carrier_name` | `?[]const u8` | Commercial brand associated with the mobile carrier. |
| `elevation` | `?[]const u8` | Average height of city above sea level in metres. |
| `usage_type` | `?[]const u8` | Usage type classification of the ISP or company. |
| `address_type` | `?[]const u8` | IP address types as defined in IPv4 and IPv6. |
| `category` | `?[]const u8` | The domain category based on IAB Tech Lab Content Taxonomy. |
| `district` | `?[]const u8` | District or county name. |
| `asn` | `?[]const u8` | Autonomous system number (ASN). |
| `as_name` | `?[]const u8` | Autonomous system (AS) name. |
| `as_domain` | `?[]const u8` | Domain name of the AS registrant. |
| `as_usage_type` | `?[]const u8` | Usage type of the AS registrant. |
| `as_cidr` | `?[]const u8` | CIDR range for the whole AS. |

A field is null when the database does not carry it or the record has no value for it. Every string is a slice into the BIN file as stored.

## Errors

| Error | Meaning |
| --- | --- |
| `error.InvalidAddress` | The text is not an IPv4 or IPv6 address. |
| `error.AddressNotFound` | No range in the database contains the address. |
| `error.Ipv6NotInDatabase` | An IPv6 address was given to an IPv4-only database. |
| `error.InvalidDatabase` | The header or a record points outside the file, or the file is an IP2Proxy database. |

`Database.open` also returns the usual file and memory-map errors.
