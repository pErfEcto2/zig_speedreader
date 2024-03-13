const std = @import("std");

const print = std.debug.print;
const sleep = std.time.sleep;

const MyErrors = error{
    NoFileProvided,
    NoSuchFile,
};

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    var wpm: f32 = 300.0;
    var data: []u8 = undefined;
    var offset: usize = 1;
    defer std.process.argsFree(alloc, args);

    if (args.len < 2) {
        print("file is needed\nUSAGE: {s} [WPM] FILE\nDefault wpm is 300\n\n", .{args[0]});
        return MyErrors.NoFileProvided;
    } else if (args.len == 3) {
        offset += 1;
        wpm = std.fmt.parseFloat(f32, args[1]) catch 300.0;
    }

    data = std.fs.cwd().readFileAlloc(alloc, args[offset], std.math.maxInt(usize)) catch {
        print("no such file: {s}\n", .{args[offset]});
        return MyErrors.NoSuchFile;
    };
    defer alloc.free(data);

    const period: u64 = @intFromFloat(60.0 / wpm * 1_000.0);

    var words = std.mem.tokenizeAny(u8, data, " \n\t.,;");

    print("\x1B[2J\x1B[H", .{});
    print("Starting", .{});
    print("\n\n\n{s: ^45}\nin 2 seconds", .{"here"});
    sleep(2 * std.time.ns_per_s);

    while (words.next()) |word| {
        print("\x1B[2J\x1B[H", .{});
        print("\n\n\n{s: ^45}", .{word});
        sleep(period * std.time.us_per_s);
    }
}
