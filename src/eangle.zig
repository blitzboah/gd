const rl = @import("raylib.zig");
const std = @import("std");

pub const EAngle = struct {
    p: f32 = 0,
    y: f32 = 0,
    r: f32 = 0,

    pub fn toVector(self: EAngle) rl.c.Vector3 {
        const p_rad = self.p * std.math.pi / 180.0;
        const y_rad = self.y * std.math.pi / 180.0;
        return .{
            .x = std.math.cos(y_rad) * std.math.cos(p_rad),
            .y = std.math.sin(p_rad),
            .z = std.math.sin(y_rad) * std.math.cos(p_rad),
        };
    }

    pub fn normalize(self: *EAngle) void {
        if (self.p > 89) self.p = 89;
        if (self.p < -89) self.p = -89;
        while (self.y < -180) self.y += 360;
        while (self.y > 180) self.y -= 360;
    }
};
