const rl = @import("../raylib.zig");
const gmath = @import("gmath.zig");

const speed = 15.0;
var velocity: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
var goalVelocity: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
const jump_velocity: rl.c.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
const gravity: rl.c.Vector3 = .{ .x = 0, .y = -1, .z = 0 };

pub fn update(playerPosition: *rl.c.Vector3) void {
    if (rl.c.IsKeyDown(rl.c.KEY_W)) goalVelocity.z = speed;
    if (rl.c.IsKeyDown(rl.c.KEY_A)) goalVelocity.x = speed;
    if (rl.c.IsKeyDown(rl.c.KEY_S)) goalVelocity.z = -speed;
    if (rl.c.IsKeyDown(rl.c.KEY_D)) goalVelocity.x = -speed;

    if (rl.c.IsKeyReleased(rl.c.KEY_W)) goalVelocity.z = 0;
    if (rl.c.IsKeyReleased(rl.c.KEY_A)) goalVelocity.x = 0;
    if (rl.c.IsKeyReleased(rl.c.KEY_S)) goalVelocity.z = 0;
    if (rl.c.IsKeyReleased(rl.c.KEY_D)) goalVelocity.x = 0;

    if (rl.c.IsKeyDown(rl.c.KEY_SPACE)) {
        velocity.y = jump_velocity.y;
    }

    velocity.x = gmath.Approach(velocity.x, goalVelocity.x, rl.c.GetFrameTime() * 60);
    velocity.z = gmath.Approach(velocity.z, goalVelocity.z, rl.c.GetFrameTime() * 60);

    playerPosition.* = gmath.add(playerPosition.*, gmath.mul(velocity, rl.c.GetFrameTime()));

    if (playerPosition.y > 0) velocity = gmath.add(velocity, gmath.mul(gravity, rl.c.GetFrameTime())) else {
        playerPosition.y = 0;
        velocity.y = 0;
    }
}
