//! The result of a lookup: every field the database carries, null when the
//! database does not carry it or the record has no value for it.

const fields = @import("fields.zig");

pub const Field = fields.Field;

/// A field's value, for callers that pick fields at runtime.
pub const Value = union(enum) {
    string: []const u8,
    float: f32,
};

/// Strings point into the database's memory, so a record is valid only while
/// its `Database` is open. No allocation, no `deinit`.
pub const Record = struct {
    country_code: ?[]const u8 = null,
    country_name: ?[]const u8 = null,
    region: ?[]const u8 = null,
    city: ?[]const u8 = null,
    latitude: ?f32 = null,
    longitude: ?f32 = null,
    isp: ?[]const u8 = null,
    domain: ?[]const u8 = null,
    zip_code: ?[]const u8 = null,
    time_zone: ?[]const u8 = null,
    net_speed: ?[]const u8 = null,
    idd_code: ?[]const u8 = null,
    area_code: ?[]const u8 = null,
    weather_station_code: ?[]const u8 = null,
    weather_station_name: ?[]const u8 = null,
    mcc: ?[]const u8 = null,
    mnc: ?[]const u8 = null,
    mobile_carrier_name: ?[]const u8 = null,
    elevation: ?[]const u8 = null,
    usage_type: ?[]const u8 = null,
    address_type: ?[]const u8 = null,
    category: ?[]const u8 = null,
    district: ?[]const u8 = null,
    asn: ?[]const u8 = null,
    as_name: ?[]const u8 = null,
    as_domain: ?[]const u8 = null,
    as_usage_type: ?[]const u8 = null,
    as_cidr: ?[]const u8 = null,

    pub fn get(self: Record, field: Field) ?Value {
        return switch (field) {
            inline else => |f| {
                const value = @field(self, @tagName(f));
                if (comptime f == .latitude or f == .longitude) {
                    return if (value) |v| .{ .float = v } else null;
                }
                return if (value) |v| .{ .string = v } else null;
            },
        };
    }
};
