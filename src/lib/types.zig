const std = @import("std");

/// Determines at compile-time whether the given type represents a string literal or a byte slice.
/// Returns true if the type is a u8 array, a u8 slice, or a pointer to a u8 array.
pub fn is_literal(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .pointer => |p| p.child == u8 and (p.size == .slice or (p.size == .one and @typeInfo(p.child) == .array)),
        .array => |a| a.child == u8,
        else => false,
    };
}
