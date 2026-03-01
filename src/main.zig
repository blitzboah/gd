const std = @import("std");
const rl = @import("raylib.zig");
const movement = @import("math/movement.zig");
const gmath = @import("math/gmath.zig");
const perlin = @import("perlin.zig");
const eangle = @import("eangle.zig");
const collision = @import("collision.zig");
const aabb = @import("aabb.zig");

const vector3 = rl.c.Vector3;

pub fn main() void {
    const screenWidth = 1280;
    const screenHeight = 720;

    perlin.init(69);
    defer perlin.deinit();
    perlin.seedNoise(69);

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

    var box: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    var angView: eangle.EAngle = .{};

    const targets = [_]collision.Target{
        .{
            .position = .{ .x = 0, .y = 0, .z = -15 },
            .aabbSize = .{
                .vecMin = .{ .x = -2.5, .y = -2.5, .z = -2.5 },
                .vecMax = .{ .x = 2.5, .y = 2.5, .z = 2.5 },
            },
        },
        .{
            .position = .{ .x = 10, .y = 0, .z = -10 },
            .aabbSize = .{
                .vecMin = .{ .x = -2.5, .y = -2.5, .z = -2.5 },
                .vecMax = .{ .x = 2.5, .y = 2.5, .z = 2.5 },
            },
        },
        .{
            .position = .{ .x = -8, .y = 0, .z = -20 },
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
    const puffTime: f64 = 0.5;
    const puffStartSize: f64 = 0.3;
    const puffEndSize: f64 = 0.4;

    while (!rl.c.WindowShouldClose()) {
        movement.update(&box, angView.toVector());

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

        // draw
        rl.c.BeginDrawing();
        defer rl.c.EndDrawing();
        rl.c.ClearBackground(rl.c.BLACK);

        rl.c.BeginMode3D(camera);

        rl.c.DrawCube(box, 5, 5, 5, rl.c.BLUE);

        for (targets) |t| {
            rl.c.DrawCube(t.position, 5, 5, 5, rl.c.RED);
            const worldBox = t.aabbSize.add(t.position);
            rl.c.DrawBoundingBox(
                .{ .min = worldBox.vecMin, .max = worldBox.vecMax },
                rl.c.GREEN,
            );
        }

        if (showTracer) {
            rl.c.DrawLine3D(tracerStart, tracerEnd, rl.c.YELLOW);
        }

        if (showHit) {
            if (rl.c.GetTime() > timeOver) {
                showHit = false;
            } else {
                const size = gmath.Remap(rl.c.GetTime(), timeCreated, timeOver, puffStartSize, puffEndSize);
                rl.c.DrawSphere(hitPoint, @as(f32, @floatCast(size)), rl.c.ORANGE);
            }
        }

        rl.c.DrawGrid(10, 10);
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
