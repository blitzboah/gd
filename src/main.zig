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

const vector3 = rl.c.Vector3;

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

    var box: vector3 = .{ .x = 0, .y = 3, .z = 0 };
    var kanye: vector3 = .{ .x = 0, .y = 5, .z = 60 };
    var angView: eangle.EAngle = .{};
    var spinAngle: f32 = 0;
    const spinSpeed = 3;
    var targets = [_]collision.Target{
        .{
            .position = &kanye,
            .aabbSize = .{
                .vecMin = .{ .x = -2.5, .y = -2.5, .z = -2.5 },
                .vecMax = .{ .x = 2.5, .y = 2.5, .z = 2.5 },
            },
        },
    };

    var tracerStart: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    var tracerEnd: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    var showTracer = false;
    var hitPoint: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    var showHit = false;

    var timeCreated: f64 = undefined;
    var timeOver: f64 = undefined;
    const puffTime: f64 = 1.0;
    const puffStartSize: f64 = 0.3;
    const puffEndSize: f64 = 0.4;

    var image = rl.c.LoadImage("/home/blitz/sandbox/gd/assets/kanye.png");
    rl.c.ImageColorReplace(&image, rl.c.WHITE, rl.c.BLANK);
    const texture = rl.c.LoadTextureFromImage(image);
    std.debug.print("texture id: {}\n", .{texture.id});
    rl.c.UnloadImage(image);

    while (!rl.c.WindowShouldClose()) {
        movement.update(&box, angView.toVector());
        // movement.MoveTowards(&kanye, box, 10.0);

        for (0..targets.len) |i| {
            targets[i].position = targets[i].position;
        }

        const mousePosition = rl.c.GetMousePosition();
        const mouseDelta: rl.c.Vector2 = .{
            .x = mousePosition.x - lastMousePosition.x,
            .y = mousePosition.y - lastMousePosition.y,
        };
        lastMousePosition = mousePosition;

        // shooting
        if (rl.c.IsMouseButtonPressed(rl.c.MOUSE_BUTTON_LEFT)) {
            const v0 = gmath.add(box, (vector3){ .x = 0, .y = 1, .z = 0 });
            const v1 = gmath.add(v0, gmath.mul(angView.toVector(), 100));

            tracerStart = v0;
            showTracer = true;
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

        const playerScale = rlgl.MatrixScale(5, 5, 5);

        const playerTransform = rlgl.MatrixMultiply(playerRotation, playerScale);
        // draw

        rl.c.BeginDrawing();
        defer rl.c.EndDrawing();
        rl.c.ClearBackground(rl.c.BLACK);

        rl.c.BeginMode3D(camera);

        placeProps();
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

        bb.drawBillboard(camera, texture, kanye, 10, spinAngle, showHit);
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
        rl.c.DrawText(text, 10, 10, 20, rl.c.WHITE);
        if (showHit) {
            rl.c.DrawText("HIT!", 10, 35, 20, rl.c.ORANGE);
        }

        angView.p -= mouseDelta.y * mouseSensi;
        angView.y += mouseDelta.x * mouseSensi;
        angView.normalize();

        camera.target = box;
        camera.position = gmath.sub(box, gmath.mul(angView.toVector(), cameraOffset));
    }
}

fn placeProps() void {
    const mScaling = rlgl.MatrixScale(5, 10, 5);
    const mRotation = rlgl.MatrixRotate(.{ .x = 0, .y = 1, .z = 0 }, 30);
    const mTranslation = rlgl.MatrixTranslate(0, 5, 0);

    // TRS
    const mTransform = rlgl.MatrixMultiply(rlgl.MatrixMultiply(mTranslation, mRotation), mScaling);

    rlgl.rlPushMatrix();
    rlgl.rlMultMatrixf(&mTransform.m0);
    rl.c.DrawCube(.{ .x = 0, .y = 0, .z = 0 }, 1, 1, 1, rl.c.RED);
    rlgl.rlPopMatrix();
}
