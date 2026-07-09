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
        str.startsWith("Thi"),
        str.startsWith("thi"),
        str.endsWith("ext"),
        str.endsWith("Ext"),
    });
    std.debug.print("\tReplace \"s\" => \"z\": {any} changes made, content: {s}\n", .{
        str.replace("s", "z"),
        str.content,
    });
    str.toUppercase();
    std.debug.print("\tToUpper: {s}\n", .{str.content});
    str.toLower();
    std.debug.print("\tToLower: {s}\n", .{str.content});
}
