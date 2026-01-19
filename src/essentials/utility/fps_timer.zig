//! Better to use as few as required of these
const std = @import("std");
const cfg = @import("cfg");

    
    time_stamp: i128 = 0,
    frame_time: u64 = @divTrunc(1_000_000_000, 1),
    delta_time: u64 = 0,


    pub fn processTime(self: *Timer) void {
        
        const now = std.time.nanoTimestamp();

        if (self.time_stamp == 0) {
            self.time_stamp = now;
            self.delta_time = 1;
            return;
        }
        
        // 1. Safety check to prevent negative results from clock jitter
        if (now > self.time_stamp) {

            const elapsed: u64 = @truncate(now - self.time_stamp);

            // 2. Prevent underflow: only sleep if we are UNDER the frame budget
            if (elapsed < self.frame_time) {
                const wait_time: u64 = self.frame_time - elapsed;
                std.Thread.sleep(wait_time + cfg.limits.fps_padding);
            }
        }
        
        // 3. Update state AFTER the logic/sleep
        const post_calc = std.time.nanoTimestamp();
        
        self.delta_time = @truncate(post_calc - self.time_stamp);
        self.time_stamp = post_calc;
    }
    
    pub fn getDeltaTime(self:*Timer) f64 { return self.delta_time; }

    pub fn setFPS(self:*Timer, fps: f64) void { self.frame_time = @intFromFloat(1e9/fps); }
