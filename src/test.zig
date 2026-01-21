const d = @import("deps");
const Thread = d.Utility.LoopThread;
const std = d.std;

pub fn main() !void {
    var this_thread = Thread.main;
    defer this_thread.signalExit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var thrd = try this_thread.splitDetach(
        1, .{}, function, .{5, "sdadas"}, allocator
    );
    defer allocator.destroy(thrd);

    var count: u8 = 0;
    try this_thread.initFPS(1);
    while (!thrd.isStatus(.exited) and this_thread.loops()) {
        count += 1;
        std.debug.print("T1: count: {d}\n", .{count});
        if (count > 10) { thrd.terminate(); }
    }

    std.debug.print("prog exited!\n", .{});
}

fn function(this_thread: *Thread, val: u8, val1: []const u8) void {
    defer { 
        std.debug.print("T2: Oops, I be dead after 2 seconds\n", .{});
        Thread.sleepNs(std.time.ns_per_s*2);
        this_thread.signalExit();
    }
    while (this_thread.loops()) {
        std.debug.print("T2: I am doing something with the val {d} and val1 {s}\n", .{val,val1});
    }
}