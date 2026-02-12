const rl = @import("../raylib.zig");
const std = @import("std");

pub fn Length(v: rl.c.Vector3) f32 {
    return std.math.sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z));
}

pub fn LengthSquared(v: rl.c.Vector3) f32 {
    return (v.x * v.x) + (v.y * v.y) + (v.z * v.z);
}

pub fn sub(a: rl.c.Vector3, b: rl.c.Vector3) rl.c.Vector3 {
    return (rl.c.Vector3){ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
}

pub fn dotProduct(a: rl.c.Vector3, b: rl.c.Vector3) f32 {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}
