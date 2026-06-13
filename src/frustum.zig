const rl = @import("raylib.zig");
const std = @import("std");
const gmath = @import("math/gmath.zig");

pub const Plane = struct {
    n: rl.c.Vector3,
    d: f32,

    pub fn normalize(self: *Plane) void {
        const len = gmath.Length(self.n);
        self.n = gmath.divide(self.n, len);
        self.d /= len;
    }

    pub fn distanceTo(self: Plane, point: rl.c.Vector3) f32 {
        return gmath.dotProduct(self.n, point) + self.d;
    }
};

pub const FrustumPlane = enum(usize) { near = 0, far = 1, left = 2, right = 3, up = 4, down = 5 };

pub const Frustum = struct {
    planes: [6]Plane,

    pub fn init(m: rl.c.Matrix) Frustum {
        var f: Frustum = undefined;

        f.planes[@intFromEnum(FrustumPlane.left)] = .{
            .n = .{ .x = m.m3 + m.m0, .y = m.m7 + m.m4, .z = m.m11 + m.m8 },
            .d = m.m15 + m.m12,
        };
        f.planes[@intFromEnum(FrustumPlane.right)] = .{
            .n = .{ .x = m.m3 - m.m0, .y = m.m7 - m.m4, .z = m.m11 - m.m8 },
            .d = m.m15 - m.m12,
        };
        f.planes[@intFromEnum(FrustumPlane.down)] = .{
            .n = .{ .x = m.m3 + m.m1, .y = m.m7 + m.m5, .z = m.m11 + m.m9 },
            .d = m.m15 + m.m13,
        };
        f.planes[@intFromEnum(FrustumPlane.up)] = .{
            .n = .{ .x = m.m3 - m.m1, .y = m.m7 - m.m5, .z = m.m11 - m.m9 },
            .d = m.m15 - m.m13,
        };
        f.planes[@intFromEnum(FrustumPlane.far)] = .{
            .n = .{ .x = m.m3 - m.m2, .y = m.m7 - m.m6, .z = m.m11 - m.m10 },
            .d = m.m15 - m.m14,
        };
        f.planes[@intFromEnum(FrustumPlane.near)] = .{
            .n = .{ .x = m.m3 + m.m2, .y = m.m7 + m.m6, .z = m.m11 + m.m10 },
            .d = m.m15 + m.m14,
        };

        for (&f.planes) |*plane| plane.normalize();

        return f;
    }

    pub fn containsSphere(self: Frustum, center: rl.c.Vector3, radius: f32) bool {
        for (self.planes) |plane| {
            const dist = plane.distanceTo(center);

            if (dist + radius <= 0)
                return false;
        }

        return true;
    }
};
