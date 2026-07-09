const std = @import("std");

pub const String = @This();

content: []u8,
allocator: std.mem.Allocator,

pub const StringError = error{
    OutOfMemory,
    OutOfRange,
    EmptyString,
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

pub fn push(self: *String, src: []const u8) StringError!void {
    try self.insert(src, self.content.len);
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

pub fn startsWith(self: String, buffer: []const u8) StringError!bool {
    return try self.find(buffer) == 0;
}

pub fn endsWith(self: String, buffer: []const u8) StringError!bool {
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

pub fn toUppercase(self: *const String) void {
    for (self.content[0..self.len()], 0..self.len()) |c, i| {
        self.content[i] = std.ascii.toUpper(c);
    }
}

pub fn toLower(self: *const String) void {
    for (self.content[0..self.len()], 0..self.len()) |c, i| {
        self.content[i] = std.ascii.toLower(c);
    }
}
