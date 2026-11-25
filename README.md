# IP2Location Zig Library

IP2Location Zig library that enables the user to find the country, region or state, city, latitude and longitude, ZIP code, time zone, Internet Service Provider (ISP) or company name, domain name, net speed, area code, weather station code, weather station name, mobile country code (MCC), mobile network code (MNC) and carrier brand, elevation, usage type, address type and IAB category by IP address.

This library reads geo-location information from the **IP2Location BIN database** file and supports lookup for both IPv4 and IPv6 addresses.

## IP2Location BIN Databases

To use this library, you must download the IP2Location BIN database.

- Download Free IP2Location LITE databases at [https://lite.ip2location.com](https://lite.ip2location.com/)
- Download IP2Location commercial databases at [https://www.ip2location.com](https://www.ip2location.com/developers)

IP2Location and IP2Proxy use different BIN layouts. A PX file is rejected with `error.InvalidDatabase`; use the `ip2proxy` package for those.

## IPv4 versus IPv6 BIN Database

Below are general guidelines for determining whether to use the IPv4 BIN database or the IPv6 BIN database.

- Use the IPv4 BIN database if you just need to query for IPv4 addresses.
- Use the IPv6 BIN database if you need to query for both IPv4 and IPv6 addresses.

## Installation

```sh
zig fetch --save git+https://github.com/ip2location/ip2location-zig
```

Then in `build.zig`:

```zig
const ip2location = b.dependency("ip2location", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("ip2location", ip2location.module("ip2location"));
```

## Usage

```zig
const std = @import("std");
const ip2location = @import("ip2location");

pub fn main(init: std.process.Init) !void {
    var db = try ip2location.Database.open(init.io, "DB26.BIN");
    defer db.deinit();

    const record = try db.lookup("175.144.151.253");
    std.debug.print("{s} {s} {s}\n", .{
        record.country_code.?,
        record.region.?,
        record.city.?,
    });
}
```

`zig build example` builds the same program as `zig-out/bin/lookup`, which takes a database path and an address:

```sh
./zig-out/bin/lookup DB26.BIN 175.144.151.253
```

## How a database is held

`Database.open` memory-maps the file read-only. A multi-gigabyte database costs address space, not RAM, and each lookup touches only the pages it needs.

Lookups allocate nothing. A `Record` holds slices into the database, so keep the database open while you use them. Read-only lookups are safe to run from several threads at once.

## API

| Member | Description |
| --- | --- |
| `Database.open(io, path)` | Memory-maps a BIN file read-only. `deinit` closes it. |
| `db.deinit()` | Releases the mapping and closes the file. |
| `db.lookup(text)` | Looks up one address in IPv4 or IPv6 notation and returns a `Record`. Fails with the errors listed below. |
| `db.metadata()` | Returns the database type, column count, build date and row counts. |
| `db.supportsIpv4()` | Whether the file carries IPv4 ranges. |
| `db.supportsIpv6()` | Whether the file carries IPv6 ranges. |
| `record.get(field)` | Returns one field as `?Value`, for callers that choose fields at runtime. |

### Record fields

| Field | Type | Description |
| --- | --- | --- |
| `country_code` | `?[]const u8` | ISO 3166 two-character country code. |
| `country_name` | `?[]const u8` | Country name. |
| `region` | `?[]const u8` | Region or state name. |
| `city` | `?[]const u8` | City name. |
| `latitude` | `?f32` | Latitude in decimal degrees. |
| `longitude` | `?f32` | Longitude in decimal degrees. |
| `isp` | `?[]const u8` | Internet service provider or company name. |
| `domain` | `?[]const u8` | Domain associated with the address range. |
| `zip_code` | `?[]const u8` | Postal code. |
| `time_zone` | `?[]const u8` | Time zone as a UTC offset. |
| `net_speed` | `?[]const u8` | Connection speed classification. |
| `idd_code` | `?[]const u8` | International direct dialing code. |
| `area_code` | `?[]const u8` | Area code. |
| `weather_station_code` | `?[]const u8` | Weather station code. |
| `weather_station_name` | `?[]const u8` | Weather station name. |
| `mcc` | `?[]const u8` | Mobile country code. |
| `mnc` | `?[]const u8` | Mobile network code. |
| `mobile_carrier_name` | `?[]const u8` | Mobile carrier name. |
| `elevation` | `?[]const u8` | Elevation above sea level. |
| `usage_type` | `?[]const u8` | Usage classification of the ISP or company. |
| `address_type` | `?[]const u8` | Address type classification. |
| `category` | `?[]const u8` | IAB content category. |
| `district` | `?[]const u8` | District name. |
| `asn` | `?[]const u8` | Autonomous system number. |
| `as_name` | `?[]const u8` | Autonomous system name. |
| `as_domain` | `?[]const u8` | Domain registered to the autonomous system. |
| `as_usage_type` | `?[]const u8` | Usage classification of the autonomous system. |
| `as_cidr` | `?[]const u8` | CIDR block announced by the autonomous system. |

A field is null when the database does not carry it or the record has no value for it. Every string is a slice into the BIN file as stored (ASCII in practice, ISO-8859-1 by the format).

IPv4-mapped (`::ffff:a.b.c.d`), 6to4 (`2002::/16`) and Teredo (`2001:0000::/32`) addresses are searched as IPv4, matching the official IP2Location SDKs.

## Errors

`db.lookup` fails with:

- `error.InvalidAddress` — the text is not an IPv4 or IPv6 address.
- `error.AddressNotFound` — no range in the database contains the address.
- `error.Ipv6NotInDatabase` — an IPv6 address was given to an IPv4-only database.
- `error.InvalidDatabase` — the header or a record points outside the file, or the file is an IP2Proxy database.

`Database.open` also returns the usual file and memory-map errors.

## Tests

```sh
zig build test
```

The suite runs against the sample BIN files in `test/testdata` and has been cross-checked against the official IP2Location PHP SDK on DB1, DB3 and DB26, over IPv4 and IPv6.

## SDK or Library for Other Programming Languages

To learn about other readily available SDKs or libraries for different programming languages, please visit [https://www.ip2location.com/development-libraries](https://www.ip2location.com/development-libraries).

## Support

Email: [support@ip2location.com](mailto:support@ip2location.com)

URL: [https://www.ip2location.com](https://www.ip2location.com/)

## License

MIT, see [LICENSE](LICENSE).

