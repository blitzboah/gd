const rl = @import("../raylib.zig");
const gmath = @import("gmath.zig");

const speed = 15.0;
var velocity: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
var vecMovement: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
var goalVelocity: rl.c.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
const jump_velocity: rl.c.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
const gravity: rl.c.Vector3 = .{ .x = 0, .y = -1, .z = 0 };

pub fn update(playerPosition: *rl.c.Vector3, angView: rl.c.Vector3) void {
    if (rl.c.IsKeyDown(rl.c.KEY_W)) goalVelocity.x = speed;
    if (rl.c.IsKeyDown(rl.c.KEY_A)) goalVelocity.z = speed;
    if (rl.c.IsKeyDown(rl.c.KEY_S)) goalVelocity.x = -speed;
    if (rl.c.IsKeyDown(rl.c.KEY_D)) goalVelocity.z = -speed;

    if (rl.c.IsKeyReleased(rl.c.KEY_W)) goalVelocity.x = 0;
    if (rl.c.IsKeyReleased(rl.c.KEY_A)) goalVelocity.z = 0;
    if (rl.c.IsKeyReleased(rl.c.KEY_S)) goalVelocity.x = 0;
    if (rl.c.IsKeyReleased(rl.c.KEY_D)) goalVelocity.z = 0;

    if (rl.c.IsKeyDown(rl.c.KEY_SPACE)) {
        velocity.y = jump_velocity.y;
    }

    vecMovement.x = gmath.Approach(vecMovement.x, goalVelocity.x, rl.c.GetFrameTime() * 60);
    vecMovement.z = gmath.Approach(vecMovement.z, goalVelocity.z, rl.c.GetFrameTime() * 60);

    var vecForward = angView;
    vecForward.y = 0;

    const norm_vecForward = gmath.Normalized(vecForward);
    const vecUp: rl.c.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
    const vecRight = gmath.crossProduct(vecUp, norm_vecForward);

    velocity = gmath.add(gmath.mul(norm_vecForward, vecMovement.x), gmath.mul(vecRight, vecMovement.z));

    playerPosition.* = gmath.add(playerPosition.*, gmath.mul(velocity, rl.c.GetFrameTime()));

    if (playerPosition.y > 0) velocity = gmath.add(velocity, gmath.mul(gravity, rl.c.GetFrameTime())) else {
        playerPosition.y = 0;
        velocity.y = 0;
    }
}
