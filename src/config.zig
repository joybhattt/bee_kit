//! All the configuration that might be changed by the user as per need

const std = @import("std");
const blt = @import("builtin");

/// The size of the buffer (in bytes) used for reading from the terminal.
pub var terminal_input_buffer_size: usize = 2 * 1024;

/// The size of the buffer (in bytes) used for writing to the terminal.
pub var terminal_output_buffer_size: usize = 2 * 1024;

/// The time window (in nanoseconds) allowed for threads to sync at the start of a frame.
/// Small values reduce latency; larger values prevent frame drops on high CPU load.
pub var frame_trasition_window_ns: u64 = 3500;

/// The maximum number of active threads allowed in the engine buffer.
pub var max_threads_alive: usize = 5;

/// Counter for threads that have been initialized but since terminated.
pub var max_threads_dead: usize = 0;

/// Additional sleep time (in nanoseconds) to prevent CPU "spinning" when 
/// the main loop finishes a frame early.
pub var fps_padding_ns: u64 = 1000;

/// The number of consecutive frames a thread can miss before being flagged as .non_responsive.
pub var max_frames_skipped: usize = 5;

/// The URL/Address of the STUN server used for NAT traversal.
pub var stun_server: []const u8 = "stun.l.google.com";

/// The UDP port used to communicate with the STUN server.
pub var stun_port: u16 = 19302;

/// A fallback IP address used for network reachability checks.
pub var junk_server_IP: []const u8 = "8.8.8.8";

/// The port used for the fallback network reachability check.
pub var junk_server_port: u16 = 53;

// -------------------------------------------------------------------------------------------------
// Build Mode Flags
// -------------------------------------------------------------------------------------------------

/// True if the program is compiled in Debug mode (slow, with safety checks).
pub const is_mode_debug: bool = (blt.mode == .Debug);

/// True if compiled in ReleaseFast (no safety, high optimization).
pub const is_mode_releasefast: bool = (blt.mode == .ReleaseFast);

/// True if compiled in ReleaseSmall (binary size optimized).
pub const is_mode_releasesmall: bool = (blt.mode == .ReleaseSmall);

/// True if compiled in ReleaseSafe (optimized but retains safety checks).
pub const is_mode_releasesafe: bool = (blt.mode == .ReleaseSafe);

/// Internal flag to ensure 'Customize' is only called once during initialization.
var is_customized = false;