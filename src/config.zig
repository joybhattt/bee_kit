//! All the configuration that might be changed by the user as per need

const std = @import("std");
const blt = @import("builtin");

/// Additional sleep time (in nanoseconds) to prevent CPU "spinning" when 
/// the main loop finishes a frame early.
pub const fps_padding_ns: u64 = 1000;

/// The URL/Address of the STUN server used for NAT traversal.
pub const stun_server: []const u8 = "stun.l.google.com";

/// The UDP port used to communicate with the STUN server.
pub const stun_port: u16 = 19302;

/// A fallback IP address used for network reachability checks.
pub const junk_server_IP: []const u8 = "8.8.8.8";

/// The port used for the fallback network reachability check.
pub const junk_server_port: u16 = 53;