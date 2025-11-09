const std = @import("std");
const rl = @import("raylib.zig");
const movement = @import("math/movement.zig");

pub fn main() void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.c.InitWindow(screenWidth, screenHeight, "window");
    rl.c.SetTargetFPS(60);

    defer rl.c.CloseWindow();

    var ballPosition = rl.c.Vector2{ .x = screenWidth / 2, .y = screenHeight / 2 };

    //const fixed_dt = 1.0 / 60.0;

    while (!rl.c.WindowShouldClose()) {

        //update
        movement.update(&ballPosition);

        rl.c.BeginDrawing();
        defer rl.c.EndDrawing();

        rl.c.ClearBackground(rl.c.BLACK);

        rl.c.DrawText("e", 20, 20, 20, rl.c.WHITE);

        rl.c.DrawCircleV(ballPosition, 20, rl.c.BLUE);
    }
}
