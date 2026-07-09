const std = @import("std");
const string = @import("string");

const String = string.String;

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const buffer = "This is a text";
    std.debug.print("[]u8\n\tbuffer: {s}\n\tlen: {}\n", .{ buffer, buffer.len });

    const str = try String.from(allocator, buffer);
    std.debug.print("String\n\tcontent: {s}\n\tlen: {}\n\tContains \"is\": {any}\n\tFind \"te\": {any}\n\tRfind \"t\": {any}\n\tEquals \"{s}\": {any}\n\tCount \"i\": {any}\n", .{
        str.content,
        str.content.len,
        str.contains("is"),
        str.find("te"),
        str.rfind("t"),
        buffer,
        str.eql(buffer),
        str.count("i"),
    });
}
