//!     zig build example
//!     ./zig-out/bin/lookup DB26.BIN 175.144.151.253

const std = @import("std");
const ip2location = @import("ip2location");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    if (args.len < 3) {
        std.debug.print("usage: {s} DATABASE.bin IP\n", .{args[0]});
        return error.MissingArguments;
    }

    var db = try ip2location.Database.open(init.io, args[1]);
    defer db.deinit();

    const record = try db.lookup(args[2]);
    std.debug.print("country   {s}\n", .{record.country_code orelse "-"});
    std.debug.print("name      {s}\n", .{record.country_name orelse "-"});
    std.debug.print("region    {s}\n", .{record.region orelse "-"});
    std.debug.print("city      {s}\n", .{record.city orelse "-"});
    if (record.latitude) |v| std.debug.print("latitude  {d}\n", .{v});
    if (record.longitude) |v| std.debug.print("longitude {d}\n", .{v});
    std.debug.print("isp       {s}\n", .{record.isp orelse "-"});
    std.debug.print("asn       {s}\n", .{record.asn orelse "-"});
    std.debug.print("as        {s}\n", .{record.as_name orelse "-"});
}
