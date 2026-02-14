const std = @import("std");
const rl = @import("raylib.zig");
const movement = @import("math/movement.zig");
const gmath = @import("math/gmath.zig");
const perlin = @import("perlin.zig");

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
    camera.position = (vector3){ .x = 0, .y = 20, .z = 10 };
    camera.target = (vector3){ .x = 0, .y = 0, .z = 0 };
    camera.up = (vector3){ .x = 0, .y = 1, .z = 0 };
    camera.fovy = 50;
    camera.projection = rl.c.CAMERA_PERSPECTIVE;
    rl.c.DisableCursor();

    var box: vector3 = .{ .x = 0, .y = 0, .z = 0 };
    const evil_box_1: vector3 = .{ .x = 0, .y = 0, .z = -15 };
    var eb_color = rl.c.WHITE;
    const backstab_distance = 5.0;
    //const evil_box_2: vector3 = .{ .x = 10, .y = 0, .z = 10 };

    while (!rl.c.WindowShouldClose()) {
        movement.update(&box);
        rl.c.UpdateCamera(&camera, rl.c.CAMERA_THIRD_PERSON);

        rl.c.BeginDrawing();
        defer rl.c.EndDrawing();

        rl.c.ClearBackground(rl.c.BLACK);

        rl.c.BeginMode3D(camera);

        rl.c.DrawCube(box, 5, 5, 5, rl.c.BLUE);
        rl.c.DrawCube(evil_box_1, 5, 5, 5, eb_color);
        //rl.c.DrawCube(evil_box_2, 5, 5, 5, rl.c.ORANGE);

        rl.c.DrawGrid(10, 10);

        rl.c.EndMode3D();

        // const be = gmath.sub(evil_box_1, box);
        // const norm = gmath.Normalized(be);

        const eb = gmath.sub(box, evil_box_1);
        const norm_eb = gmath.Normalized(eb);

        if (rl.c.IsKeyDown(rl.c.KEY_LEFT_CONTROL) and gmath.Length(gmath.sub(evil_box_1, box)) < backstab_distance) {
            const dotProd = gmath.dotProduct(norm_eb, gmath.Normalized(evil_box_1));
            if (dotProd < 0) {
                eb_color = rl.c.RED;
            }
        }

        const view = gmath.add(box, evil_box_1);
        //const v2 = gmath.sub(box, evil_box_2);

        const text = rl.c.TextFormat("view vecotr: %.2f, %.2f, %.2f", view.x, view.y, view.z);
        rl.c.DrawText(text, 10, 10, 20, rl.c.WHITE);

        //var x: f64 = 0;
        //while (x < 50) : (x += 1) {
        //    var z: f64 = 0;
        //    while (z < 50) : (z += 1) {
        //        const height = std.math.clamp(perlin.noise2(@as(f64, @floatCast(x * 0.05)), @as(f64, @floatCast(z * 0.05))) * 50, 0, 50); //magic numbahhh
        //        rl.c.DrawCube((vector3){
        //            .x = @as(f32, @floatCast(x)),
        //            .y = @as(f32, @floatCast(@floor(height))),
        //            .z = @as(f32, @floatCast(z)),
        //        }, 1, 1, 1, rl.c.ColorAlpha(if (height > 15) rl.c.GREEN else rl.c.SKYBLUE, @as(f32, @floatCast(height / 50))));
        //    }
        //}
    }
}
