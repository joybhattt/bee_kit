//! All the configuration that might be changed by the user as per need

pub const buffer_size = struct {
    pub const terminal_input: usize = 1024;
    // pub const log_output: usize = 4096;
};

pub const limits = struct {
    pub const fps_padding: c_uint = 1000;

pub const thread = struct {
    pub const non_respo_min: usize = 10;
    pub const termination_min: usize = 70;
    pub const count_max: usize = 5;
};
  
    /// in `Hz` or `loops per sec`
    pub const loop_fps_min: usize = 1;
};

pub const sources = struct {
    pub const stun_server: []const u8 = "stun.l.google.com";
    pub const stun_port: u16 = 19302;
    pub const junk_server_IP: []const u8 = "8.8.8.8";
    pub const junk_server_port: u16 = 53;
};

pub const default = struct {

};
