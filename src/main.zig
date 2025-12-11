const std = @import("std");
const rl = @import("raylib.zig");
const movement = @import("math/movement.zig");
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
    camera.position = (vector3){ .x = 0, .y = 10, .z = 10 };
    camera.target = (vector3){ .x = 0, .y = 0, .z = 0 };
    camera.up = (vector3){ .x = 0, .y = 1, .z = 0 };
    camera.fovy = 50;
    camera.projection = rl.c.CAMERA_PERSPECTIVE;
    rl.c.DisableCursor();

    //const fixed_dt = 1.0 / 60.0;

    while (!rl.c.WindowShouldClose()) {
        //movement.update(&boxPosition);
        rl.c.UpdateCamera(&camera, rl.c.CAMERA_FREE);

        rl.c.BeginDrawing();
        defer rl.c.EndDrawing();

        rl.c.ClearBackground(rl.c.BLACK);

        rl.c.BeginMode3D(camera);
        defer rl.c.EndMode3D();

        var x: f64 = 0;
        while (x < 50) : (x += 1) {
            var z: f64 = 0;
            while (z < 50) : (z += 1) {
                const height = std.math.clamp(perlin.noise2(@as(f64, @floatCast(x * 0.05)), @as(f64, @floatCast(z * 0.05))) * 50, 0, 50); //magic numbahhh
                rl.c.DrawCube((vector3){
                    .x = @as(f32, @floatCast(x)),
                    .y = @as(f32, @floatCast(@floor(height))),
                    .z = @as(f32, @floatCast(z)),
                }, 1, 1, 1, rl.c.ColorAlpha(if (height > 15) rl.c.GREEN else rl.c.SKYBLUE, @as(f32, @floatCast(height / 50))));
            }
        }
    }
}
