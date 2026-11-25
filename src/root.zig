//! Zig reader for the IP2Location BIN databases, DB1 through DB26.
//!
//! ```zig
//! var db = try ip2location.Database.open(io, "DB26.BIN");
//! defer db.deinit();
//!
//! const record = try db.lookup("175.144.151.253");
//! std.debug.print("{s}, {s}, {s}\n", .{
//!     record.country_code.?,
//!     record.region.?,
//!     record.city.?,
//! });
//! ```
//!
//! `Database.open` memory-maps the file, so a database larger than RAM is fine.
//! Lookups allocate nothing and a `Record` borrows the database's memory.

pub const Database = @import("database.zig").Database;
pub const Error = @import("database.zig").Error;
pub const Metadata = @import("database.zig").Metadata;

pub const Field = @import("record.zig").Field;
pub const Record = @import("record.zig").Record;
pub const Value = @import("record.zig").Value;

test {
    _ = @import("database.zig");
    _ = @import("record.zig");
}
