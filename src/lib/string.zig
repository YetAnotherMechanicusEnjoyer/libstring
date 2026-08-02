const std = @import("std");
const types = @import("types.zig");

/// A dynamic string type managed by an allocator.
pub const String = @This();

content: []u8,
allocator: std.mem.Allocator,

/// Errors that can occur during String operations.
pub const StringError = error{
    OutOfMemory,
    OutOfRange,
    EmptyString,
    WrongType,
    NotFound,
};

/// Initializes an empty String with the given allocator.
pub fn init(allocator: std.mem.Allocator) String {
    return .{
        .content = "",
        .allocator = allocator,
    };
}

/// Frees the memory allocated for the string's content.
pub fn deinit(self: *const String) void {
    self.allocator.free(self.content);
}

/// Reallocates the string's content buffer to the specified size.
pub fn allocate(self: *const String, size: usize) StringError!void {
    @constCast(self).content = self.allocator.realloc(self.content, size) catch {
        return StringError.OutOfMemory;
    };
}

/// Creates a newly allocated String from an existing byte slice.
pub fn from(allocator: std.mem.Allocator, content: []const u8) StringError!String {
    const str = @constCast(&String.init(allocator));
    try str.push(content);
    return str.*;
}

/// Creates a deep copy of the current String.
pub fn clone(self: String) StringError!String {
    return try String.from(self.allocator, self.content);
}

/// Returns the string's content as a mutable byte slice.
pub fn as_literal(self: String) []u8 {
    return self.content;
}

/// Appends a single byte (u8) or a string literal/slice to the end of the string.
pub fn push(self: *String, src: anytype) StringError!void {
    const T = @TypeOf(src);

    if (T == u8) {
        const c = [_]u8{src};
        try self.insert(&c, self.content.len);
    } else if (comptime types.is_literal(T)) {
        const s: []const u8 = if (@typeInfo(T) == .array) &src else src;
        try self.insert(s, self.content.len);
    } else {
        @compileError("Expected u8 or []u8, found: " ++ @typeName(T));
    }
}

/// Inserts a string slice into the string at the specified index.
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

/// Checks if the string's content is exactly equal to the provided buffer.
pub fn eql(self: String, buffer: []const u8) bool {
    return std.mem.eql(u8, self.content, buffer);
}

/// Returns the length of the string in bytes.
pub fn len(self: String) usize {
    return self.content.len;
}

/// Checks if the string contains the specified substring.
pub fn contains(self: String, buffer: []const u8) StringError!?bool {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.containsAtLeast(u8, self.content, 1, buffer);
}

/// Finds the first occurrence of the specified substring and returns its index.
pub fn find(self: String, buffer: []const u8) StringError!?usize {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.indexOf(u8, self.content, buffer);
}

/// Finds the last occurrence of the specified substring and returns its index.
pub fn rfind(self: String, buffer: []const u8) StringError!?usize {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.lastIndexOf(u8, self.content, buffer);
}

/// Counts the number of times the specified substring appears in the string.
pub fn count(self: String, buffer: []const u8) StringError!usize {
    if (buffer.len == 0) {
        return StringError.EmptyString;
    }
    return std.mem.count(u8, self.content, buffer);
}

/// Checks if the string starts with the specified prefix.
pub fn starts_with(self: String, buffer: []const u8) StringError!bool {
    return try self.find(buffer) == 0;
}

/// Checks if the string ends with the specified suffix.
pub fn ends_with(self: String, buffer: []const u8) StringError!bool {
    if (buffer.len > self.len()) {
        return StringError.OutOfRange;
    }
    return try self.rfind(buffer) == self.len() - buffer.len;
}

/// Replaces all occurrences of needle with replacement in the string.
/// Modifies the string in place and returns the number of replacements made.
pub fn replace(self: *const String, needle: []const u8, replacement: []const u8) StringError!usize {
    if (needle.len == 0) {
        return StringError.EmptyString;
    }
    const new_size = std.mem.replacementSize(u8, self.content, needle, replacement);
    try self.allocate(new_size);
    return std.mem.replace(u8, self.content[0..self.len()], needle, replacement, self.content);
}

/// Converts all ASCII characters in the string to uppercase in place.
pub fn to_uppercase(self: *const String) void {
    for (self.content[0..self.len()], 0..self.len()) |c, i| {
        self.content[i] = std.ascii.toUpper(c);
    }
}

/// Converts all ASCII characters in the string to lowercase in place.
pub fn to_lowercase(self: *const String) void {
    for (self.content) |*c| {
        c.* = std.ascii.toLower(c.*);
    }
}

/// Overwrites the string's content with null bytes (0).
pub fn clear(self: *const String) void {
    for (self.content) |*c| {
        c.* = 0;
    }
}

/// Splits the string by the specified delimiter and returns an allocated slice of Strings.
/// The caller is responsible for freeing the returned slice and its internal strings.
pub fn split(self: String, buffer: []const u8) StringError![]String {
    var arr: std.ArrayList(String) = .empty;
    defer arr.deinit(self.allocator);

    const null_char: u8 = 0;
    const copy = try self.clone();
    defer copy.deinit();

    _ = try copy.replace(buffer, &[_]u8{null_char});
    var i: usize = 0;
    while (i < copy.len()) {
        while (i < copy.len() and copy.content[i] == null_char) {
            i += 1;
        }
        const buff = String.init(self.allocator);
        defer buff.deinit();
        while (i < copy.len() and copy.content[i] != null_char) {
            try @constCast(&buff).push(copy.content[i]);
            i += 1;
        }
        try arr.append(self.allocator, try buff.clone());
    }

    return try arr.toOwnedSlice(self.allocator);
}

/// Splits the string at the first occurrence of the delimiter.
/// Returns a slice containing exactly two Strings: the part before and the part after the delimiter.
/// The caller is responsible for freeing the returned slice and its internal strings.
pub fn split_once(self: String, buffer: []const u8) StringError![]String {
    const idx = try self.find(buffer);
    if (idx == null) {
        return StringError.OutOfRange;
    }
    const i = idx.?;

    if (i + buffer.len >= self.len()) {
        return StringError.OutOfRange;
    }

    var arr: std.ArrayList(String) = .empty;
    defer arr.deinit(self.allocator);

    const left = try String.from(self.allocator, self.content[0..i]);
    const right = try String.from(self.allocator, self.content[i + buffer.len .. self.len()]);

    try arr.append(self.allocator, left);
    try arr.append(self.allocator, right);

    return try arr.toOwnedSlice(self.allocator);
}

/// Splits the string at the last occurrence of the delimiter.
/// Returns a slice containing exactly two Strings: the part before and the part after the delimiter.
/// The caller is responsible for freeing the returned slice and its internal strings.
pub fn rsplit_once(self: String, buffer: []const u8) StringError![]String {
    const idx = try self.rfind(buffer);
    if (idx == null) {
        return StringError.NotFound;
    }
    const i = idx.?;

    if (i + buffer.len >= self.len()) {
        return StringError.OutOfRange;
    }

    var arr: std.ArrayList(String) = .empty;
    defer arr.deinit(self.allocator);

    const left = try String.from(self.allocator, self.content[0..i]);
    const right = try String.from(self.allocator, self.content[i + buffer.len .. self.len()]);

    try arr.append(self.allocator, left);
    try arr.append(self.allocator, right);

    return try arr.toOwnedSlice(self.allocator);
}
