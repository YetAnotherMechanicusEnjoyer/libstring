const std = @import("std");
const string = @import("string");

const String = string.String;

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const buffer = "This is a text";
    std.debug.print("[]u8\n\tbuffer: {s}\n\tlen: {}\n", .{ buffer, buffer.len });

    const str = try String.from(allocator, buffer);
    defer str.deinit();
    std.debug.print("String\n\tcontent: {s}\n\tlen: {}\n", .{
        str.content,
        str.content.len,
    });

    try string_search(str, buffer);
    try string_replacement(str);
    try string_splitting(str);

    str.clear();
    std.debug.print("\tClear: content: {s}, len: {}\n", .{ str.content, str.len() });
}

fn string_search(str: String, buffer: []const u8) !void {
    std.debug.print("\tContains \"is\": {any}\n", .{str.contains("is")});
    std.debug.print("\tFind \"te\": {any}\n\tRfind \"t\": {any}\n", .{
        str.find("te"),
        str.rfind("t"),
    });
    std.debug.print("\tEquals \"{s}\": {any}\n\tCount \"i\": {any}\n", .{
        buffer,
        str.eql(buffer),
        str.count("i"),
    });
    std.debug.print("\tStartsWith \"Thi\" & \"thi\": {any} & {any}\n\tEndsWith \"ext\" & \"Ext\": {any} & {any}\n", .{
        str.starts_with("Thi"),
        str.starts_with("thi"),
        str.ends_with("ext"),
        str.ends_with("Ext"),
    });
}

fn string_replacement(str: String) !void {
    std.debug.print("\tReplace \"s\" => \"z\": {any} changes made, content: {s}\n", .{
        str.replace("s", "z"),
        str.content,
    });
    str.to_uppercase();
    std.debug.print("\tToUpper: {s}\n", .{str.content});
    str.to_lowercase();
    std.debug.print("\tToLower: {s}\n", .{str.content});
    const split = try str.split(" ");
    std.debug.print("\tSplit \"{s}\" \" \":\n", .{str.content});
    for (split) |s| {
        std.debug.print("\t\t>>> {s}\n", .{s.content});
    }
}

fn string_splitting(str: String) !void {
    const split_once = try str.split_once(" ");
    std.debug.print("\tSplitOnce \"{s}\" \" \":\n\t\t>>> {s}\n\t\t>>> {s}\n", .{ str.content, split_once[0].content, split_once[1].content });
    const rsplit_once = try str.rsplit_once(" ");
    std.debug.print("\tRsplitOnce \"{s}\" \" \":\n\t\t>>> {s}\n\t\t>>> {s}\n", .{ str.content, rsplit_once[0].content, rsplit_once[1].content });
}
