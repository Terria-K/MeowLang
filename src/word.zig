const std = @import("std");

words: []const u8,
len: usize,

pub fn init(words: []const u8) @This() {
    return .{
        .words = words,
        .len = words.len
    };
}

pub fn isCorrect(self: @This(), line: []const u8, current: *usize, lineNum: u32) bool {
    for (1..self.len) |i| {
        if (current.* + i >= line.len) {
            std.log.err("Compiler error at Ln {d} Col {d}", .{lineNum + 1, current.* + 2});
            return false;
        }
        const ch = line[current.* + i];
        if (ch != self.words[i]) {
            std.log.err("Compiler error at Ln {d} Col {d}", .{lineNum + 1, current.* + 2});
            return false;
        }
    }

    current.* += self.len - 1;
    return true;
}