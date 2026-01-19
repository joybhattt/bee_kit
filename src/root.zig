// external modules
const zio = @import("zio");

/// `zio.net`
pub const net = zio.net;
/// `zio`
pub const io = zio;


// zig modules
/// `zig "std"`
pub const std = @import("std");
/// `zig "builtin"`
pub const bltn = @import("builtin");

// internal modules
/// configurations set at compile time
pub const cfg = @import("config.zig");