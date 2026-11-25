# Quickstart

## Dependencies

This library requires an IP2Location BIN database to function. You may download the BIN database at

- IP2Location LITE BIN Data (Free): <https://lite.ip2location.com>
- IP2Location Commercial BIN Data (Comprehensive): <https://www.ip2location.com>

:::{note}
Sample BIN files are provided in the `test/testdata` folder for testing. You are recommended to visit the above links to download the latest BIN database.
:::

This library requires Zig 0.16.0. It memory-maps the BIN file, so the database may be larger than available RAM.

## Installation

```sh
zig fetch --save git+https://github.com/<org>/ip2location-zig
```

Then add the module in `build.zig`:

```zig
const ip2location = b.dependency("ip2location", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("ip2location", ip2location.module("ip2location"));
```

## Sample Codes

### Query geolocation information from BIN database

You can query the geolocation information from the IP2Location BIN database as below:

```zig
const std = @import("std");
const ip2location = @import("ip2location");

pub fn main(init: std.process.Init) !void {
    var db = try ip2location.Database.open(init.io, "DB26.BIN");
    defer db.deinit();

    const record = try db.lookup("8.8.8.8");
    std.debug.print("{s} {s} {s}\n", .{
        record.country_code.?,
        record.region.?,
        record.city.?,
    });
}
```

`Database.open` memory-maps the file read-only, and `db.deinit` releases the mapping. A `Record` borrows the database's memory, so keep the database open while you use it.
