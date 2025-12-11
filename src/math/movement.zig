const rl = @import("../raylib.zig");

const speed = 3.0;

pub fn update(playerPosition: *rl.c.Vector3) void {
    if (rl.c.IsKeyDown(rl.c.KEY_W)) playerPosition.z -= 1.0 * speed * rl.c.GetFrameTime();
    if (rl.c.IsKeyDown(rl.c.KEY_A)) playerPosition.x -= 1.0 * speed * rl.c.GetFrameTime();
    if (rl.c.IsKeyDown(rl.c.KEY_S)) playerPosition.z += 1.0 * speed * rl.c.GetFrameTime();
    if (rl.c.IsKeyDown(rl.c.KEY_D)) playerPosition.x += 1.0 * speed * rl.c.GetFrameTime();
}
