const std = @import("std");
const rl = @import("raylib.zig");
const movement = @import("math/movement.zig");
const vector3 = rl.c.Vector3;

pub fn main() void {
    const screenWidth = 1280;
    const screenHeight = 720;

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

    const boxPosition = vector3{ .x = 0, .y = 0, .z = 0 };

    //const fixed_dt = 1.0 / 60.0;

    while (!rl.c.WindowShouldClose()) {
        //movement.update(&boxPosition);
        rl.c.UpdateCamera(&camera, rl.c.CAMERA_FREE);

        rl.c.BeginDrawing();
        defer rl.c.EndDrawing();

        rl.c.ClearBackground(rl.c.BLACK);

        rl.c.BeginMode3D(camera);
        defer rl.c.EndMode3D();

        rl.c.DrawCube(boxPosition, 2, 2, 2, rl.c.BLUE);
        rl.c.DrawCubeWires(boxPosition, 2, 2, 2, rl.c.WHITE);

        rl.c.DrawGrid(10, 1);

        rl.c.DrawText("e", 20, 20, 20, rl.c.WHITE);
    }
}
