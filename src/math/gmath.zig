const rl = @import("../raylib.zig");
const std = @import("std");

pub fn Length(v: rl.c.Vector3) f32 {
    return std.math.sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z));
}

pub fn LengthSquared(v: rl.c.Vector3) f32 {
    return (v.x * v.x) + (v.y * v.y) + (v.z * v.z);
}

pub fn Normalized(v: rl.c.Vector3) rl.c.Vector3 {
    var normalized: rl.c.Vector3 = undefined;

    normalized = divide(v, Length(v));

    return normalized;
}

pub fn Approach(flCurrent: f32, flGoal: f32, dt: f32) f32 {
    const diff = flGoal - flCurrent;
    if (diff > dt) return flCurrent + dt;

    if (diff < -dt) return flCurrent - dt;

    return flGoal;
}

pub fn add(a: rl.c.Vector3, b: rl.c.Vector3) rl.c.Vector3 {
    return (rl.c.Vector3){ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
}

pub fn sub(a: rl.c.Vector3, b: rl.c.Vector3) rl.c.Vector3 {
    return (rl.c.Vector3){ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
}

pub fn mul(v: rl.c.Vector3, factor: f32) rl.c.Vector3 {
    return (rl.c.Vector3){ .x = v.x * factor, .y = v.y * factor, .z = v.z * factor };
}

pub fn divide(v: rl.c.Vector3, factor: f32) rl.c.Vector3 {
    return (rl.c.Vector3){ .x = v.x / factor, .y = v.y / factor, .z = v.z / factor };
}

pub fn dotProduct(a: rl.c.Vector3, b: rl.c.Vector3) f32 {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

pub fn crossProduct(a: rl.c.Vector3, b: rl.c.Vector3) rl.c.Vector3 {
    var c: rl.c.Vector3 = undefined;

    c.x = a.y * b.z - a.z * b.y;
    c.y = a.z * b.x - a.x * b.z;
    c.z = a.x * b.y - a.y * b.x;

    return c;
}
