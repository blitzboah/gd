const rl = @import("raylib.zig");
const gmath = @import("math/gmath.zig");

pub const AABB = struct {
    vecMin: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 },
    vecMax: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 },

    pub fn add(self: AABB, p: rl.c.Vector3) AABB {
        return .{
            .vecMin = gmath.add(self.vecMin, p),
            .vecMax = gmath.add(self.vecMax, p),
        };
    }
};
