const std = @import("std");
const ip2location = @import("ip2location");

const db1_ipv4_path = "test/testdata/IP2LOCATION-LITE-DB11-SAMPLE.BIN";
const db1_ipv6_path = "test/testdata/IP2LOCATION-LITE-DB1.IPV6.BIN";

fn expectCode(db: *const ip2location.Database, ip: []const u8, code: []const u8) !void {
    const record = try db.lookup(ip);
    try std.testing.expect(record.country_code != null);
    try std.testing.expectEqualStrings(code, record.country_code.?);
}

test "IPv4 country lookup" {
    var threaded: std.Io.Threaded = .init(std.testing.allocator, .{});
    defer threaded.deinit();
    var db = try ip2location.Database.open(threaded.io(), db1_ipv4_path);
    defer db.deinit();

    try expectCode(&db, "8.8.8.8", "US");
    try expectCode(&db, "1.1.1.1", "AU");
    try expectCode(&db, "175.144.151.253", "??");
    try expectCode(&db, "255.255.255.255", "??");
}

test "IPv6 lookup and IPv4 forms" {
    var threaded: std.Io.Threaded = .init(std.testing.allocator, .{});
    defer threaded.deinit();
    var db = try ip2location.Database.open(threaded.io(), db1_ipv6_path);
    defer db.deinit();

    try expectCode(&db, "8.8.8.8", "US");
    try expectCode(&db, "175.144.151.253", "MY");
    try expectCode(&db, "2001:4860:4860::8888", "US");
    try expectCode(&db, "2404:6800:4003:c00::8a", "SG");
    try expectCode(&db, "::ffff:8.8.8.8", "US");
    try expectCode(&db, "2002:0808:0808::1", "US");
}

test "metadata and field support" {
    var threaded: std.Io.Threaded = .init(std.testing.allocator, .{});
    defer threaded.deinit();
    var db = try ip2location.Database.open(threaded.io(), db1_ipv4_path);
    defer db.deinit();

    const meta = db.metadata();
    try std.testing.expectEqual(@as(u8, 1), meta.db_type);
    try std.testing.expectEqual(@as(u16, 2014), meta.year);
    try std.testing.expectEqual(@as(u8, 12), meta.month);
    try std.testing.expectEqual(@as(u8, 18), meta.day);
    try std.testing.expect(db.supportsIpv4());
    try std.testing.expect(!db.supportsIpv6());

    const record = try db.lookup("8.8.8.8");
    try std.testing.expectEqualStrings("United States", record.country_name.?);
    try std.testing.expect(record.region == null);
    try std.testing.expect(record.city == null);
    try std.testing.expect(record.latitude == null);
    try std.testing.expect(record.asn == null);
}

test "runtime field access" {
    var threaded: std.Io.Threaded = .init(std.testing.allocator, .{});
    defer threaded.deinit();
    var db = try ip2location.Database.open(threaded.io(), db1_ipv4_path);
    defer db.deinit();

    const record = try db.lookup("8.8.8.8");
    try std.testing.expectEqualStrings("US", record.get(.country_code).?.string);
    try std.testing.expectEqualStrings("United States", record.get(.country_name).?.string);
    try std.testing.expect(record.get(.city) == null);
}

test "invalid input" {
    var threaded: std.Io.Threaded = .init(std.testing.allocator, .{});
    defer threaded.deinit();
    var db = try ip2location.Database.open(threaded.io(), db1_ipv4_path);
    defer db.deinit();

    try std.testing.expectError(ip2location.Error.InvalidAddress, db.lookup("not an ip"));
    try std.testing.expectError(ip2location.Error.Ipv6NotInDatabase, db.lookup("2001:4860:4860::8888"));
}
