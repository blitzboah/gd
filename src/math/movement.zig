const rl = @import("../raylib.zig");

const speed = 2.0;

pub fn update(playerPosition: *rl.c.Vector2) void {
    if (rl.c.IsKeyDown(rl.c.KEY_W)) playerPosition.y -= 1.0 * speed;
    if (rl.c.IsKeyDown(rl.c.KEY_A)) playerPosition.x -= 1.0 * speed;
    if (rl.c.IsKeyDown(rl.c.KEY_S)) playerPosition.y += 1.0 * speed;
    if (rl.c.IsKeyDown(rl.c.KEY_D)) playerPosition.x += 1.0 * speed;
}
