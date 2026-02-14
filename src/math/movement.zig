const rl = @import("../raylib.zig");
const gmath = @import("gmath.zig");

const speed = 3.0;
var velocity: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
const jump_velocity: rl.c.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
const gravity: rl.c.Vector3 = .{ .x = 0, .y = -1, .z = 0 };

pub fn update(playerPosition: *rl.c.Vector3) void {
    if (rl.c.IsKeyDown(rl.c.KEY_W)) playerPosition.z -= 1.0 * speed * rl.c.GetFrameTime();
    if (rl.c.IsKeyDown(rl.c.KEY_A)) playerPosition.x -= 1.0 * speed * rl.c.GetFrameTime();
    if (rl.c.IsKeyDown(rl.c.KEY_S)) playerPosition.z += 1.0 * speed * rl.c.GetFrameTime();
    if (rl.c.IsKeyDown(rl.c.KEY_D)) playerPosition.x += 1.0 * speed * rl.c.GetFrameTime();

    if (rl.c.IsKeyDown(rl.c.KEY_SPACE)) {
        velocity = jump_velocity;
    }

    playerPosition.* = gmath.add(playerPosition.*, velocity);
    if (playerPosition.y > 0) velocity = gmath.add(velocity, gmath.mul(gravity, rl.c.GetFrameTime())) else {
        playerPosition.y = 0;
        velocity.y = 0;
    }
}
