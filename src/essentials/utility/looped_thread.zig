//! syncronized threads  
//! Pro: always start processing at the same time at the start of the frame as they employ cond var  
//! Con: they can run at a multiple of the lowest fps only  
//! Note: threads are not meant to communicate bilaterally in the same frame  
//! Note: always .aquire at the start of frame and .release at end for shared storage atomics  
//! Note: they need to be sybcronized by one timer in the main thread  

// -------------------------------------------------------------------------------------------------
// Imports
// -------------------------------------------------------------------------------------------------
const std = @import("std");
const cfg = @import("root").Configuration;

// -------------------------------------------------------------------------------------------------
// Class Declation
// -------------------------------------------------------------------------------------------------
pub const LoopThread = struct {

    // -------------------------------------------------------------------------------------------------
    // Fields
    // -------------------------------------------------------------------------------------------------
    _frame_time: u64 = 0,                                       // 8 b
    _thread: std.Thread = undefined,                            // 8 b
    _delta_time: f64 = 0,                                       // 8 b
    _timer: std.time.Timer = undefined,                         // 8 b

    _status: std.atomic.Value(Status) = .init(.not_initialized),// 1 b
    _terminate_now : std.atomic.Value(bool) = .init(false),     // 1 b
    // 6 remain

    pub var main : LoopThread = .{};

    // -------------------------------------------------------------------------------------------------
    // Enums
    // -------------------------------------------------------------------------------------------------
    const Status = enum(u8) {
        not_initialized,
        terminated,
        exited,
        asleep,
        active,
        presumed_dead,
    };

    // -------------------------------------------------------------------------------------------------
    // Meathods
    // -------------------------------------------------------------------------------------------------

    pub fn splitDetach(
        main_: *LoopThread,
        fps: f32,
        spawn_config: std.Thread.SpawnConfig,
        comptime function: anytype,
        args: anytype,
        allocator: std.mem.Allocator,
    ) !*LoopThread {
        _ = main_;

        var self = try allocator.create(LoopThread);
        self._frame_time = @intFromFloat(@as(f32, std.time.ns_per_s) / fps);
        self._timer = try std.time.Timer.start();
        self._status.store(.active, .release);

        // Create a local struct to hold the "Closure"
        const Closure = struct {
            thread_ptr: *LoopThread,
            captured_args: @TypeOf(args),

            fn wrapper(c: @This()) void {
                // This 'splats' the tuple back into the function arguments
                @call(.auto, function, .{c.thread_ptr} ++ c.captured_args);
            }
        };

        self._thread = try std.Thread.spawn(spawn_config, Closure.wrapper, .{Closure{
            .thread_ptr = self,
            .captured_args = args,
        }});
        
        self._thread.detach();

        return self;
    }



    pub fn initFPS(self: *LoopThread, fps: f32) !void {
        self._frame_time = @intFromFloat(@as(f32,std.time.ns_per_s)/fps);
        self._timer = try std.time.Timer.start();
        self._status.store(.active, .release);
    }

    pub fn signalExit(self: *LoopThread) void {
        self._timer.reset();
        self._status.store(.exited, .release);
    }

    /// remember to call `this_thread.signalAsleep();` first
    pub fn sleepNs(duration: u64) void { std.Thread.sleep(duration); }

    pub fn terminate(self: *LoopThread) void {
        self._timer.reset();
        self._terminate_now.store(true, .release);
    }

    pub fn presumeDead(self: *LoopThread) void {
        self._timer.reset();
        self._status.store(.presumed_dead, .release);
    }

    pub fn signalAsleep(self: *LoopThread) void {
        self._timer.reset();
        self._status.store(.asleep, .release);
    }

    pub fn signalAwake(self: *LoopThread) void {    
        self._timer.reset();
        self._status.store(.active, .release);
    }

    pub fn isStatus(self: *const LoopThread,stat: Status) bool {
        return (self.getStatus() == stat);
    }

    /// put inside the while expression
    /// must be called inside the thread only
    pub fn loops(self: *LoopThread) bool {
        const stat = self._status.load(.monotonic);

        if (self._terminate_now.load(.monotonic)) {
            self._timer.reset();
            self._status.store(.terminated, .release);   
            return false;
        }

        switch (stat) {
            .active, .not_initialized=> {
                const diff = self._frame_time - self._timer.read(); 
                if (diff > 0) {
                    sleepNs(diff + cfg.fps_padding_ns);
                    self._delta_time = @as(f64,@floatFromInt(self._timer.lap())) * 1e-9; 
                    self._status.store(.active, .release);
                } else { // frames too close
                    self._delta_time = 0;
                    self._timer.reset();
                    self._status.store(.active, .release);
                }
            },
            .asleep, .terminated, .presumed_dead, .exited, => unreachable,
        }

        if (self._terminate_now.load(.monotonic)) {
            self._timer.reset();
            self._status.store(.terminated, .release);   
            return false;
        }
        return true;
    }

    /// insidea while loop in the main thread, make sure to sleep optimize the loop
    pub fn getStatus(self: *const LoopThread) Status {
        return self._status.load(.monotonic);
    }

    const StatusNFrames = struct {status: Status, frames: u8};
    pub fn getStatusNFrames(self: *const LoopThread) StatusNFrames {
        
        const stat = self._status.load(.acquire);
        const frames = self._timer.read()/self._frame_time;

        return .{
            .status = stat,
            .frames = if (frames < 255) frames orelse 255,
        };

    }

    const StatusNNs = struct { status: Status, nano_sec: u64};
    pub fn getStatusNNs(self: *LoopThread) StatusNNs {
        // By using 'const', you force the sequence of events
        const status = self._status.load(.acquire);
        const ns = self._timer.read(); 
        
        return .{
            .status = status,
            .nano_sec = ns,
        };
    }

};