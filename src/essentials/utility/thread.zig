//! syncronized threads  
//! Pro: always start processing at the same time at the start of the frame as they employ cond var  
//! Con: they can run at a multiple of the lowest fps only  
//! Note: threads are not meant to communicate bilaterally in the same frame  
//! Note: always .aquire at the start of frame and .release at end for shared storage atomics  
//! Note: they need to be sybcronized by one timer in the main thread  

const r = @import("deps");
const std = r.std;
const cfg = r.cfg;
const bltn = r.bltn;
const wrapCall = r.util.wrapCall;

/// read_only
status: std.atomic.Value(Status) = .init(.not_initialized),
time_stamp: i128 = 0,
thread: std.Thread = undefined,
is_spot_taken: bool = false,

var insts: ?*[]@This() = null;

pub fn init(allocator: std.mem.Allocator) !void {
    if ( comptime bltn.mode == .Debug ) {
        if(insts != null) return error.DoubleInit;
    }
    insts.? = try allocator.alloc(@This(),cfg.limits.thread.count_max);
}

pub fn deinit(allocator: std.mem.Allocator) void {
    if ( comptime bltn.mode == .Debug ) {
        if(insts == null) return error.DoubleDeInit;
    }
    allocator.free(insts.?);
}

const ThreadHandle = enum(u8){




};

pub fn create() !ThreadHandle {
    if ( comptime bltn.mode == .Debug ) {
        if(insts == null) return error.NotInited;
    }
    const ins = insts.?;

    for (ins.*) |i| {
        if(i.is_spot_taken) continue;

        else 
    }
}

/// shared sychronizing thread blocker
const Status = enum(u8) {
    pressumed_dead,
    termination_requested,
    terminated,
    asleep,
    not_initialized,
    active,
    non_responsive,
};

/// put inside the while expression
/// must be called inside the thread only
pub fn loops(self: *@This()) !bool {
    if (self._status.load(.acquire) == .termination_requested) {
        self._status.store(.terminated, .release);
        return false;
    }
    self.gate.wait();
    self.time_stamp = std.time.nanoTimestamp();
    return true;
}

/// insidea while loop in the main thread, make sure to sleep optimize the loop at 20Hz or
pub fn getStatus(self: *Thread) Status {
    // Ensure we don't have a negative result if clocks slightly misalign
    const now = std.time.nanoTimestamp();
    const last = self.time_stamp;

    const diff = now - last;
    if (diff < 0) return .active; // clock glitches only happen if the frames were too close

    const num_of_frames_behind = @divTrunc(diff, self.loop.frame_time);

    const stat = self._status.load(.acquire);
    if (@intFromEnum(stat) < @intFromEnum(Status.active)) return stat;

    return switch (num_of_frames_behind) {
        0...cfg => .active,

        cfg.limits.thread_non_respo_min + 0...cfg.limits.thread_termination_min => {
            return .non_responsive;
        },

        else => {
            self.terminate();
            return .termination_requested;
        },
    };
}

pub fn terminate(self: *Thread) void {
    self._status.store(.termination_requested, .release);
}

pub fn signalAsleep(self: *Thread) void {
    self._status.store(.asleep, .release);
}

pub fn signalAwake(self: *Thread) void {
    self._status.store(.active, .release);
    self.loop.time_stamp = std.time.nanoTimestamp();
}

/// remember to call `this_thread.setDormant();` first
pub fn sleepNanos(duration: u64) void {
    std.Thread.sleep(duration);
}

pub fn isStatus(self:*const @This, status: Status) bool {
    return (self.getStatus() == status);
}
