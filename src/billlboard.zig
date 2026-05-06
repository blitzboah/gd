const rlgl = @cImport(@cInclude("rlgl.h"));
const rl = @import("raylib.zig");
const std = @import("std");
const gmath = @import("math/gmath.zig");

fn applySpinY(vecRight: rl.c.Vector3, angle: f32) rl.c.Vector3 {
    const rad = angle * std.math.pi / 180.0;
    const c = @cos(rad);
    const s = @sin(rad);

    return rl.c.Vector3{
        .x = vecRight.x * c - vecRight.z * s,
        .y = vecRight.y,
        .z = -vecRight.x * s + vecRight.z * c,
    };
}

pub fn drawBillboard(camera: rl.c.Camera3D, tex: rl.c.Texture2D, pos: rl.c.Vector3, size: f32, angle: f32, isShot: bool) void {
    const vecGlobalUp = rl.c.Vector3{ .x = 0, .y = 1, .z = 0 };

    const vecForward = gmath.Normalized(gmath.sub(pos, camera.position));
    var vecRight = gmath.Normalized(gmath.crossProduct(vecGlobalUp, vecForward));

    if (isShot) {
        vecRight = gmath.Normalized(applySpinY(vecRight, angle));
    }

    const vecUp = if (isShot) vecGlobalUp else gmath.Normalized(gmath.crossProduct(vecForward, vecRight));

    const half = size / 2.0;
    const tl = gmath.add(pos, gmath.add(gmath.mul(vecRight, -half), gmath.mul(vecUp, half)));
    const tr = gmath.add(pos, gmath.add(gmath.mul(vecRight, half), gmath.mul(vecUp, half)));
    const br = gmath.add(pos, gmath.add(gmath.mul(vecRight, half), gmath.mul(vecUp, -half)));
    const bl = gmath.add(pos, gmath.add(gmath.mul(vecRight, -half), gmath.mul(vecUp, -half)));

    rlgl.rlSetTexture(tex.id);
    rlgl.rlBegin(rlgl.RL_QUADS);
    rlgl.rlColor4ub(255, 255, 255, 255);

    rlgl.rlTexCoord2f(0, 0);
    rlgl.rlVertex3f(tl.x, tl.y, tl.z);
    rlgl.rlTexCoord2f(1, 0);
    rlgl.rlVertex3f(tr.x, tr.y, tr.z);
    rlgl.rlTexCoord2f(1, 1);
    rlgl.rlVertex3f(br.x, br.y, br.z);
    rlgl.rlTexCoord2f(0, 1);
    rlgl.rlVertex3f(bl.x, bl.y, bl.z);

    rlgl.rlEnd();
    rlgl.rlSetTexture(0);
}
