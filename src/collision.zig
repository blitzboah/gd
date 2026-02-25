const rl = @import("raylib.zig");
const aabb = @import("aabb.zig");
const gmath = @import("math/gmath.zig");

pub const Target = struct {
    position: rl.c.Vector3,
    aabbSize: aabb.AABB,
};

fn clipLine(d: u2, aabbBox: aabb.AABB, v0: rl.c.Vector3, v1: rl.c.Vector3, f_low: *f32, f_high: *f32) bool {
    const box_min = switch (d) {
        0 => aabbBox.vecMin.x,
        1 => aabbBox.vecMin.y,
        2 => aabbBox.vecMin.z,
        else => unreachable,
    };
    const box_max = switch (d) {
        0 => aabbBox.vecMax.x,
        1 => aabbBox.vecMax.y,
        2 => aabbBox.vecMax.z,
        else => unreachable,
    };
    const ray0 = switch (d) {
        0 => v0.x,
        1 => v0.y,
        2 => v0.z,
        else => unreachable,
    };
    const ray1 = switch (d) {
        0 => v1.x,
        1 => v1.y,
        2 => v1.z,
        else => unreachable,
    };

    var f_dim_low = (box_min - ray0) / (ray1 - ray0);
    var f_dim_high = (box_max - ray0) / (ray1 - ray0);

    if (f_dim_high < f_dim_low) {
        const tmp = f_dim_high;
        f_dim_high = f_dim_low;
        f_dim_low = tmp;
    }

    if (f_dim_high < f_low.*) return false;
    if (f_dim_low > f_high.*) return false;

    f_low.* = @max(f_dim_low, f_low.*);
    f_high.* = @min(f_dim_high, f_high.*);

    if (f_low.* > f_high.*) return false;

    return true;
}

pub fn lineAABBIntersection(
    aabbBox: aabb.AABB,
    v0: rl.c.Vector3,
    v1: rl.c.Vector3,
    vecIntersection: *rl.c.Vector3,
    fraction: *f32,
) bool {
    var f_low: f32 = 0;
    var f_high: f32 = 1;

    if (!clipLine(0, aabbBox, v0, v1, &f_low, &f_high)) return false;
    if (!clipLine(1, aabbBox, v0, v1, &f_low, &f_high)) return false;
    if (!clipLine(2, aabbBox, v0, v1, &f_low, &f_high)) return false;

    const b = gmath.sub(v1, v0);
    vecIntersection.* = gmath.add(v0, gmath.mul(b, f_low));
    fraction.* = f_low;

    return true;
}

pub fn traceLine(
    targets: []const Target,
    v0: rl.c.Vector3,
    v1: rl.c.Vector3,
    vecIntersection: *rl.c.Vector3,
) bool {
    var lowestFraction: f32 = 1.0;
    var hit = false;
    var testIntersection: rl.c.Vector3 = undefined;
    var testFraction: f32 = undefined;

    for (targets) |target| {
        const worldBox = target.aabbSize.add(target.position);
        if (lineAABBIntersection(worldBox, v0, v1, &testIntersection, &testFraction)) {
            if (testFraction < lowestFraction) {
                lowestFraction = testFraction;
                vecIntersection.* = testIntersection;
                hit = true;
            }
        }
    }

    return hit;
}
