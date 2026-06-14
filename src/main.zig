const std = @import("std");
const rl = @import("raylib.zig");
const movement = @import("math/movement.zig");
const gmath = @import("math/gmath.zig");
const eangle = @import("eangle.zig");
const collision = @import("collision.zig");
const aabb = @import("aabb.zig");
const rlgl = @cImport({
    @cInclude("raymath.h");
    @cInclude("rlgl.h");
});
const bb = @import("billlboard.zig");
const frustum = @import("frustum.zig");

const vector3 = rl.c.Vector3;

pub const Entity = struct {
    mTransform: rlgl.Matrix,
    mTransformInverse: rlgl.Matrix,
    boundingRadius: f32 = 0,

    pub fn SetTransform(self: *Entity, vecScaling: rl.c.Vector3, flTheta: f32, vecRotationAxis: rl.c.Vector3, vecTranslation: rl.c.Vector3) void {
        const mScaling = rlgl.MatrixScale(vecScaling.x, vecScaling.y, vecScaling.z);
        const mRotation = rlgl.MatrixRotate(@bitCast(vecRotationAxis), flTheta);
        const mTranslation = rlgl.MatrixTranslate(vecTranslation.x, vecTranslation.y, vecTranslation.z);

        self.mTransform = rlgl.MatrixTranspose(rlgl.MatrixMultiply(
            mScaling,
            rlgl.MatrixMultiply(mRotation, mTranslation),
        ));

        self.mTransformInverse = rlgl.MatrixInvert(self.mTransform);

        const hx = vecScaling.x * 0.5;
        const hy = vecScaling.y * 0.5;
        const hz = vecScaling.z * 0.5;
        self.boundingRadius = gmath.Length(.{ .x = hx, .y = hy, .z = hz });
    }

    pub fn getPosition(self: *Entity) rl.c.Vector3 {
        return .{
            .x = self.mTransform.m3,
            .y = self.mTransform.m7,
            .z = self.mTransform.m11,
        };
    }
};

pub fn main() void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.c.InitWindow(screenWidth, screenHeight, "window");
    rl.c.SetTargetFPS(60);
    defer rl.c.CloseWindow();

    var camera: rl.c.Camera3D = undefined;
    camera.position = (vector3){ .x = 0, .y = 0, .z = 0 };
    camera.up = (vector3){ .x = 0, .y = 1, .z = 0 };
    camera.fovy = 50;
    camera.projection = rl.c.CAMERA_PERSPECTIVE;
    rl.c.DisableCursor();

    const cameraOffset = 30;
    const mouseSensi = 0.1;
    var lastMousePosition: rl.c.Vector2 = rl.c.GetMousePosition();

    var entityCount: u64 = 0;
    var box: vector3 = .{ .x = 0, .y = 3, .z = 0 };
    var angView: eangle.EAngle = .{};
    var spinAngle: f32 = 0;
    const spinSpeed = 3;

    var tracerStart: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    var tracerEnd: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    const showTracer = true;
    var hitPoint: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    var showHit = false;

    var timeCreated: f64 = undefined;
    var timeOver: f64 = undefined;
    const puffTime: f64 = 1.0;
    const puffStartSize: f64 = 0.3;
    const puffEndSize: f64 = 0.4;

    var prop1: Entity = .{
        .mTransform = rlgl.MatrixIdentity(),
        .mTransformInverse = rlgl.MatrixIdentity(),
    };
    var kanye: Entity = .{
        .mTransform = rlgl.MatrixIdentity(),
        .mTransformInverse = rlgl.MatrixIdentity(),
    };

    var prop2: Entity = .{
        .mTransform = rlgl.MatrixIdentity(),
        .mTransformInverse = rlgl.MatrixIdentity(),
    };

    var kanyePos: vector3 = .{ .x = 10, .y = 0, .z = 10 };

    var targets = [_]collision.Target{
        .{
            .entity = &kanye,
            .aabbSize = .{
                .vecMin = .{ .x = -0.5, .y = -0.5, .z = -0.5 },
                .vecMax = .{ .x = 0.5, .y = 0.5, .z = 0.5 },
            },
        },
        .{
            .entity = &prop1,
            .aabbSize = .{
                .vecMin = .{ .x = -0.5, .y = -0.5, .z = -0.5 },
                .vecMax = .{ .x = 0.5, .y = 0.5, .z = 0.5 },
            },
        },
        .{
            .entity = &prop2,
            .aabbSize = .{
                .vecMin = .{ .x = -0.5, .y = -0.5, .z = -0.5 },
                .vecMax = .{ .x = 0.5, .y = 0.5, .z = 0.5 },
            },
        },
    };

    var image = rl.c.LoadImage("/home/blitz/sandbox/gd/assets/kanye.png");
    rl.c.ImageColorReplace(&image, rl.c.WHITE, rl.c.BLANK);
    const texture = rl.c.LoadTextureFromImage(image);
    rl.c.UnloadImage(image);

    var f: frustum.Frustum = undefined;
    std.debug.print("forward: ({d:.3}, {d:.3}, {d:.3})\n", .{
        angView.toVector().x,
        angView.toVector().y,
        angView.toVector().z,
    });
    while (!rl.c.WindowShouldClose()) {
        entityCount = 0;
        movement.update(&box, angView.toVector());
        movement.MoveTowards(&kanyePos, box, 10.0);
        prop1.SetTransform(
            .{ .x = 5, .y = 10, .z = 5 }, // scale
            30.0 * std.math.pi / 180.0, // theta (radians)
            .{ .x = 0, .y = 1, .z = 0 }, // axis
            .{ .x = 50, .y = 5, .z = 0 }, // translation
        );

        prop2.SetTransform(
            .{ .x = 5, .y = 1, .z = 5 }, // scale
            0, // theta (radians)
            .{ .x = 0, .y = 1, .z = 0 }, // axis
            .{ .x = 10, .y = 5, .z = 0 }, // translation
        );

        kanye.SetTransform(
            .{ .x = 4, .y = 1, .z = 1 },
            0,
            .{ .x = 0, .y = 1, .z = 0 },
            kanyePos,
        );
        const mousePosition = rl.c.GetMousePosition();
        const mouseDelta: rl.c.Vector2 = .{
            .x = mousePosition.x - lastMousePosition.x,
            .y = mousePosition.y - lastMousePosition.y,
        };
        lastMousePosition = mousePosition;

        angView.p -= mouseDelta.y * mouseSensi;
        angView.y += mouseDelta.x * mouseSensi;
        angView.normalize();

        camera.target = box;
        camera.position = gmath.sub(box, gmath.mul(angView.toVector(), cameraOffset));

        // shooting
        if (rl.c.IsMouseButtonPressed(rl.c.MOUSE_BUTTON_LEFT)) {
            const v0 = gmath.add(box, (vector3){ .x = 0, .y = 1, .z = 0 });
            const v1 = gmath.add(v0, gmath.mul(angView.toVector(), 100));

            tracerStart = v0;
            showHit = false;

            var vecIntersection: vector3 = undefined;
            if (collision.traceLine(&targets, v0, v1, &vecIntersection)) {
                tracerEnd = vecIntersection;
                hitPoint = vecIntersection;
                showHit = true;

                timeCreated = rl.c.GetTime();
                timeOver = rl.c.GetTime() + puffTime;
            } else {
                tracerEnd = v1;
            }
        }

        // matrix for char movement

        // const playerTranslation = rlgl.MatrixTranslate(box.x, box.y, box.z);

        var vecForward: rl.c.Vector3 = angView.toVector();
        vecForward.y = 0;
        vecForward = gmath.Normalized(vecForward);

        const vecUp = rl.c.Vector3{ .x = 0, .y = 1, .z = 0 };
        const vecRight = gmath.Normalized(gmath.crossProduct(gmath.mul(vecUp, -1), vecForward));

        const playerRotation = rlgl.Matrix{
            .m0 = vecRight.x,
            .m4 = vecRight.y,
            .m8 = vecRight.z,
            .m12 = 0,

            .m1 = vecUp.x,
            .m5 = vecUp.y,
            .m9 = vecUp.z,
            .m13 = 0,

            .m2 = vecForward.x,
            .m6 = vecForward.y,
            .m10 = vecForward.z,
            .m14 = 0,

            .m3 = 0,
            .m7 = 0,
            .m11 = 0,
            .m15 = 1,
        };

        const v = rlgl.MatrixLookAt(
            @bitCast(camera.position),
            @bitCast(camera.target),
            @bitCast(camera.up),
        );

        const p = rlgl.MatrixPerspective(
            camera.fovy * std.math.pi / 180.0,
            @as(f32, screenWidth) / @as(f32, screenHeight),
            0.1,
            100,
        );
        const vp = rlgl.MatrixMultiply(v, p);
        f = frustum.Frustum.init(@bitCast(vp));

        const playerScale = rlgl.MatrixScale(5, 5, 5);

        const playerTransform = rlgl.MatrixMultiply(playerRotation, playerScale);
        // draw

        rl.c.BeginDrawing();
        defer rl.c.EndDrawing();
        rl.c.ClearBackground(rl.c.BLACK);

        rl.c.BeginMode3D(camera);
        if (f.containsSphere(prop1.getPosition(), prop1.boundingRadius)) {
            entityCount += 1;
            drawEntity(&prop1);
        }
        if (f.containsSphere(prop2.getPosition(), prop2.boundingRadius)) {
            entityCount += 1;
            drawEntity(&prop2);
        }

        bb.drawBillboard(camera, texture, kanyePos, 10, spinAngle, showHit);

        rlgl.rlPushMatrix();

        rlgl.rlTranslatef(box.x, box.y, box.z);

        rlgl.rlMultMatrixf(&playerTransform.m0);
        rl.c.DrawCube(.{ .x = 0, .y = 0, .z = 0 }, 1, 1, 1, rl.c.BLUE);

        rlgl.rlPopMatrix();

        if (showTracer) {
            rl.c.DrawLine3D(tracerStart, tracerEnd, rl.c.YELLOW);
        }

        if (showHit) {
            if (rl.c.GetTime() > timeOver) {
                showHit = false;
            } else {
                spinAngle += 360 * rl.c.GetFrameTime() * spinSpeed;
                const size = gmath.Remap(rl.c.GetTime(), timeCreated, timeOver, puffStartSize, puffEndSize);
                rl.c.DrawSphere(hitPoint, @as(f32, @floatCast(size)), rl.c.ORANGE);
            }
        }

        rl.c.BeginBlendMode(rl.c.BLEND_ALPHA);

        // const source = rl.c.Rectangle{
        //     .x = 0,
        //     .y = 0,
        //     .width = @floatFromInt(texture.width),
        //     .height = @floatFromInt(texture.height),
        // };

        // const size = rl.c.Vector2{ .x = 10, .y = 10 };
        // const origin = rl.c.Vector2{ .x = 5, .y = 5 };

        // fuck it let's implement it, cuz raylib's kinda baked axis shit

        // rl.c.DrawBillboardPro(camera, texture, source, kanye, .{ .x = 0, .y = 1, .z = 0 }, size, origin, if (showHit) spinAngle else 0, rl.c.WHITE);
        // basically billboarding is way to show sprite to camera always facing to it
        // and scaling param here, probably does matrix multiplication but for all dimension

        rl.c.EndBlendMode();

        rl.c.DrawGrid(25, 25);
        rl.c.EndMode3D();

        const text = rl.c.TextFormat(
            "pos: %.1f, %.1f, %.1f",
            box.x,
            box.y,
            box.z,
        );
        const entityCountText = rl.c.TextFormat("rendered entity count: %d", entityCount);
        rl.c.DrawText(text, 10, 10, 20, rl.c.WHITE);
        rl.c.DrawText(entityCountText, 10, 30, 20, rl.c.BLUE);
        if (showHit) {
            rl.c.DrawText("HIT!", 10, 35, 20, rl.c.ORANGE);
        }
    }
}

fn drawEntity(p: *Entity) void {
    rlgl.rlPushMatrix();
    rlgl.rlMultMatrixf(@ptrCast(&p.mTransform));
    rl.c.DrawCube(.{ .x = 0, .y = 0, .z = 0 }, 1, 1, 1, rl.c.RED);
    rlgl.rlPopMatrix();
}
