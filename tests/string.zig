const std = @import("std");
const testing = std.testing;

const string = @import("string");
const String = string.String;
const StringError = string.StringError;

test "String init" {
    const allocator = testing.allocator;
    const str = String.init(allocator);
    defer str.deinit();
    try testing.expect(@TypeOf(str) == String);
}

test "String from" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    try testing.expect(std.mem.eql(u8, str.content, buffer));
    try testing.expectEqual(str.content.len, buffer.len);
}

test "String contains" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    const is = try str.contains("is");
    const isnt = try str.contains("isn't");

    try testing.expect(is.?);
    try testing.expect(!isnt.?);
}

test "String find" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    try testing.expectEqual((try str.find("te")).?, 10);
    try testing.expectEqual((try str.rfind("t")).?, 13);
    try testing.expectError(StringError.EmptyString, str.find(""));
    try testing.expectError(StringError.EmptyString, str.rfind(""));
}

test "String eql" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    try testing.expect(str.eql(buffer));
    try testing.expect(!str.eql("This is not a text"));
}

test "String count" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    try testing.expectEqual(try str.count("i"), 2);
    try testing.expectError(StringError.EmptyString, str.count(""));
}

test "String starts_with" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    try testing.expect(try str.starts_with("Thi"));
    try testing.expect(!try str.starts_with("thi"));
    try testing.expectError(StringError.EmptyString, str.starts_with(""));
}

test "String ends_with" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    try testing.expect(try str.ends_with("ext"));
    try testing.expect(!try str.ends_with("Ext"));
    try testing.expectError(StringError.EmptyString, str.ends_with(""));
}

test "String replace" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    const changes = str.replace("s", "z");

    try testing.expectEqual(changes, 2);
    try testing.expect(std.mem.eql(u8, str.content, "Thiz iz a text"));
    try testing.expectError(StringError.EmptyString, str.replace("", ""));
}

test "String to_uppercase" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    str.to_uppercase();

    try testing.expect(std.mem.eql(u8, str.content, "THIS IS A TEXT"));
}

test "String to_lowercase" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    str.to_lowercase();

    try testing.expect(std.mem.eql(u8, str.content, "this is a text"));
}

test "String split" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    const split = try str.split(" ");
    defer {
        for (split) |s| {
            s.deinit();
        }
        std.mem.Allocator.free(allocator, split);
    }
    const slice = [_][:0]const u8{ "This", "is", "a", "text" };

    try testing.expectEqual(slice.len, split.len);
    for (0..slice.len) |idx| {
        try testing.expect(std.mem.eql(u8, split[idx].content, slice[idx]));
    }
}

test "String split_once" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    const split = try str.split_once(" ");
    defer {
        for (split) |s| {
            s.deinit();
        }
        std.mem.Allocator.free(allocator, split);
    }
    const slice = [_][:0]const u8{ "This", "is a text" };

    try testing.expectEqual(slice.len, split.len);
    for (0..slice.len) |idx| {
        try testing.expect(std.mem.eql(u8, split[idx].content, slice[idx]));
    }
}

test "String rsplit_once" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    const split = try str.rsplit_once(" ");
    defer {
        for (split) |s| {
            s.deinit();
        }
        std.mem.Allocator.free(allocator, split);
    }
    const slice = [_][:0]const u8{ "This is a", "text" };

    try testing.expectEqual(slice.len, split.len);
    for (0..slice.len) |idx| {
        try testing.expect(std.mem.eql(u8, split[idx].content, slice[idx]));
    }
}

test "String clear" {
    const allocator = testing.allocator;
    const buffer = "This is a text";

    const str = try String.from(allocator, buffer);
    defer str.deinit();

    str.clear();

    try testing.expectEqual(str.content.len, buffer.len);
    try testing.expect(std.mem.eql(u8, str.content, &[_:0]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }));
}
