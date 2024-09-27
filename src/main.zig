const std = @import("std");
const Word = @import("word.zig");

fn getFileArgs() ![]const u8 {
    const allocator = std.heap.page_allocator;

    var argsIterator = try std.process.ArgIterator.initWithAllocator(allocator);
    defer argsIterator.deinit();

    _ = argsIterator.skip();

    if (argsIterator.next()) |file| {
        return file;
    } else {
        return error.NoArgs;
    }
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const filePath = getFileArgs() catch {
        std.log.err("No file is given in the argument. Please specify an input file", .{});
        return;
    };
    var allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close();

    const size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, size);
    defer allocator.free(buffer);
    _ = try file.readAll(buffer);

    const blocks = try allocator.alloc(u8, 255);
    @memset(blocks, 0);
    defer allocator.free(blocks);

    const meow = Word.init("meow");
    const woem = Word.init("woem");
    const purr = Word.init("purr");
    const rrup = Word.init("rrup");
    const feed = Word.init("feed");

    var lineNum: u32 = 0;
    var currentBlock: u8 = 0;
    var commented = false;

    var isLooping = false;
    var currentLine: usize = 0;
    var currentColumn: usize = 0;

    var splitted = std.mem.split(u8, buffer, " ");

    while (splitted.next()) |line| {
        var i: usize = 0;
        while (i < line.len) {
            const c = line[i];
            switch (c) {
                ':' => if (!commented) {
                    currentBlock +%= 1;
                },
                '3' => if (!commented) {
                    currentBlock -%= 1;
                },
                'm' => if (!commented) {
                    if (meow.isCorrect(line, &i, lineNum)) {
                        blocks.ptr[currentBlock] +%= 1;
                    } else {
                        return;
                    }
                },
                'w' => if (!commented) {
                    if (woem.isCorrect(line, &i, lineNum)) {
                        blocks.ptr[currentBlock] -%= 1;
                    } else {
                        return;
                    }
                },
                'p' => if (!commented) {
                    if (purr.isCorrect(line, &i, lineNum)) {
                        currentColumn = i + 1;
                        currentLine = splitted.index.?;
                        isLooping = true;
                    } else {
                        return;
                    }
                },
                'f' => if (!commented) {
                    if (feed.isCorrect(line, &i, lineNum)) {
                        try stdout.print("{c}", .{blocks.ptr[currentBlock]});
                    } else {
                        return;
                    }
                },
                'r' => if (!commented) {
                    if (rrup.isCorrect(line, &i, lineNum)) {
                        if (!isLooping) {
                            std.log.err("Loop has not even started yet. Ln {d} Col {d}", .{lineNum + 1, i + 1});
                            return;
                        }

                        if (blocks.ptr[currentBlock] == 0) {
                            isLooping = false;
                        } else {
                            i = currentColumn - 1;
                            splitted.index = currentLine;
                        }
                    }
                },
                '(' => if (!commented) {
                    commented = true;
                },
                ')' => commented = false,
                else => {}
            }
            i += 1;
        }

        lineNum += 1;
    }

    try bw.flush();
}