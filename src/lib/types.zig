const std = @import("std");

pub fn is_literal(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .pointer => |p| p.child == u8 and (p.size == .slice or (p.size == .one and @typeInfo(p.child) == .array)),
        .array => |a| a.child == u8,
        else => false,
    };
}
