const std = @import("std");
const types = @import("types.zig");

pub const String = @This();

content: []u8,
allocator: std.mem.Allocator,

pub const StringError = error{
    OutOfMemory,
    OutOfRange,
    EmptyString,
    WrongType,
    NotFound,
};

pub fn init(allocator: std.mem.Allocator) String {
    return .{
        .content = "",
        .allocator = allocator,
    };
}

pub fn deinit(self: *const String) void {
    self.allocator.free(self.content);
}

pub fn allocate(self: *const String, size: usize) StringError!void {
    @constCast(self).content = self.allocator.realloc(self.content, size) catch {
        return StringError.OutOfMemory;
    };
}

pub fn from(allocator: std.mem.Allocator, content: []const u8) StringError!String {
    const str = @constCast(&String.init(allocator));
    try str.push(content);
    return str.*;
}

pub fn clone(self: String) StringError!String {
    return try String.from(self.allocator, self.content);
}

pub fn push(self: *String, src: anytype) StringError!void {
    const T = @TypeOf(src);

    if (T == u8) {
        const c = [_]u8{src};
        try self.insert(&c, self.content.len);
    } else if (comptime types.is_literal(T)) {
        const s: []const u8 = if (@typeInfo(T) == .array) &src else src;
        try self.insert(s, self.content.len);
    } else {
        @compileError("Expected u8 or []u8, found: {}" ++ @typeName(T));
    }
}

pub fn insert(self: *const String, src: []const u8, idx: usize) StringError!void {
    if (idx > self.content.len) {
        return StringError.OutOfRange;
    }
    if (self.content.len < self.content.len + src.len) {
        try self.allocate(self.content.len + src.len);
    }

    var i: usize = 0;
    while (i < src.len) {
        self.content[idx + i] = src[i];
        i += 1;
    }
}

pub fn eql(self: String, buffer: []const u8) bool {
    return std.mem.eql(u8, self.content, buffer);
}

pub fn len(self: String) usize {
    return self.content.len;
}

pub fn contains(self: String, buffer: []const u8) StringError!?bool {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.containsAtLeast(u8, self.content, 1, buffer);
}

pub fn find(self: String, buffer: []const u8) StringError!?usize {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.indexOf(u8, self.content, buffer);
}

pub fn rfind(self: String, buffer: []const u8) StringError!?usize {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.lastIndexOf(u8, self.content, buffer);
}

pub fn count(self: String, buffer: []const u8) StringError!usize {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.count(u8, self.content, buffer);
}

pub fn starts_with(self: String, buffer: []const u8) StringError!bool {
    return try self.find(buffer) == 0;
}

pub fn ends_with(self: String, buffer: []const u8) StringError!bool {
    if (buffer.len > self.len()) {
        return StringError.OutOfRange;
    }
    return try self.rfind(buffer) == self.len() - buffer.len;
}

pub fn replace(self: *const String, needle: []const u8, replacement: []const u8) !usize {
    if (needle.len == 0) {
        return StringError.EmptyString;
    }
    const new_size = std.mem.replacementSize(u8, self.content, needle, replacement);
    try self.allocate(new_size);
    return std.mem.replace(u8, self.content[0..self.len()], needle, replacement, self.content);
}

pub fn to_uppercase(self: *const String) void {
    for (self.content[0..self.len()], 0..self.len()) |c, i| {
        self.content[i] = std.ascii.toUpper(c);
    }
}

pub fn to_lowercase(self: *const String) void {
    for (self.content) |*c| {
        c.* = std.ascii.toLower(c.*);
    }
}

pub fn clear(self: *const String) void {
    for (self.content) |*c| {
        c.* = 0;
    }
}

pub fn split(self: String, buffer: []const u8) ![]String {
    var arr: std.ArrayList(String) = .empty;
    errdefer arr.deinit(self.allocator);

    const null_char: u8 = 0;
    const copy = try self.clone();

    _ = try copy.replace(buffer, &[_]u8{null_char});
    var i: usize = 0;
    while (i < copy.len()) {
        while (i < copy.len() and copy.content[i] == null_char) {
            i += 1;
        }
        const buff = String.init(self.allocator);
        while (i < copy.len() and copy.content[i] != null_char) {
            try @constCast(&buff).push(copy.content[i]);
            i += 1;
        }
        try arr.append(self.allocator, try buff.clone());
    }

    return try arr.toOwnedSlice(self.allocator);
}

pub fn split_once(self: String, buffer: []const u8) ![]String {
    const idx = try self.find(buffer);
    if (idx == null) {
        return StringError.OutOfRange;
    }
    const i = idx.?;

    if (i + buffer.len >= self.len()) {
        return StringError.OutOfRange;
    }
    var arr: std.ArrayList(String) = .empty;
    try arr.append(self.allocator, try String.from(self.allocator, self.content[0..i]));
    try arr.append(self.allocator, try String.from(self.allocator, self.content[i + buffer.len .. self.len()]));

    return try arr.toOwnedSlice(self.allocator);
}

pub fn rsplit_once(self: String, buffer: []const u8) ![]String {
    const idx = try self.rfind(buffer);
    if (idx == null) {
        return StringError.NotFound;
    }
    const i = idx.?;

    if (i + buffer.len >= self.len()) {
        return StringError.OutOfRange;
    }
    var arr: std.ArrayList(String) = .empty;
    try arr.append(self.allocator, try String.from(self.allocator, self.content[0..i]));
    try arr.append(self.allocator, try String.from(self.allocator, self.content[i + buffer.len .. self.len()]));

    return try arr.toOwnedSlice(self.allocator);
}
