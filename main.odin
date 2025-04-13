package game

import rl "vendor:raylib";

import "core:fmt"
import "core:os"
import "core:mem"

import "core:math/linalg"

MyVars :: struct
{
    cubeModel : rl.Model,
    cubeMesh :rl.Mesh,
    cubeMat : rl.Material,
    cam : rl.Camera3D,
    dtOver : f64,
    physicsTimeStep : u64,
    player : PlayerEntity,
};


g_vars : MyVars

main :: proc()
{
    rl.InitWindow(1280, 720, "Testing odin raylib");
    init();
    defer deinit();
    for !rl.WindowShouldClose()
    {
        update();
        render();
    }
}

init :: proc()
{
    g_vars.cam = {
        position = {0, 10, 5},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 90,
        projection = .PERSPECTIVE,
    };
    g_vars.cubeMesh = rl.GenMeshCube(1, 1, 1);
    g_vars.cubeModel = rl.LoadModelFromMesh(g_vars.cubeMesh);
    g_vars.cubeMat = rl.LoadMaterialDefault();

    append(&g_vars.player.transform,
        TransformComponent{
            rot = quaternion(x = 0, y = 0, z = 0, w = 1),
            scale = vec4{1, 1, 1, 1}
        })

    append(&g_vars.player.offset,
        OffsetComponent{
            pos = {0, 0, 1, 0}
        })
}

draw :: proc()
{

    tmp := quaternion128{}
    for ind in 0..<len(g_vars.player.transform)
    {
        t := g_vars.player.transform[ind]
        p := g_vars.player.offset[ind]

        getRowMajor :: proc(inMat : matrix[4, 4]f32) -> #row_major matrix[4, 4]f32
        {
            outMat :#row_major matrix[4, 4]f32 // = cast(#row_major matrix[4, 4]f32)linalg.transpose(finalMat)
            for i in 0..<4
            {
                for j in 0..<4
                {
                    outMat[i][j] = inMat[j][i]
                }

            }
            return outMat;
        }
        drawCube :: proc(pos: vec4, rot: quat, scale: vec4, col: rl.Color )
        {
            tMat := linalg.matrix4_translate(pos.xyz)
            rMat := linalg.matrix4_from_quaternion(rot)
            sMat := linalg.matrix4_scale(scale.xyz);
            finalMat := tMat * rMat * sMat;

            MATERIAL_MAP_ALBEDO :: 0
            material := g_vars.cubeMat;
            material.maps[MATERIAL_MAP_ALBEDO].color = col

            rl.DrawMesh(g_vars.cubeMesh, material, getRowMajor(finalMat));
        }

        r, u, f := getDirections(t.rot)

        drawCube(t.pos, t.rot, t.scale, {255, 255, 255, 255})
        drawCube(t.pos + f, t.rot, {0.5, 0.5, 0.5, 1.0}, {0, 0, 255, 255})
        drawCube(t.pos + u, t.rot, {0.5, 0.5, 0.5, 1.0}, {0, 255, 0, 255})
        drawCube(t.pos + r, t.rot, {0.5, 0.5, 0.5, 1.0}, {255, 0, 0, 255})

        /*
        angle, axis := linalg.angle_axis_from_quaternion(t.rot)
        fmt.println(angle)
        fmt.println(axis)

        rl.DrawModelEx(g_vars.cubeModel,
            t.pos.xyz,
            axis,
            angle,
            t.scale.xyz,
            rl.Color{255, 255, 255, 255});
*/
    }
}

deinit :: proc()
{
    defer rl.CloseWindow();
}

getDirections :: proc(q: quat) -> (r: vec4, u: vec4, f: vec4)
{
    forward := [4]f32{0, 0, 1, 0};
    right := [4]f32{1, 0, 0, 0};
    up := [4]f32{0, 1, 0, 0};

    forward.xyz = linalg.quaternion128_mul_vector3(q, forward.xyz)
    right.xyz = linalg.quaternion128_mul_vector3(q, right.xyz)
    up.xyz = linalg.quaternion128_mul_vector3(q, up.xyz)

    return right, up, forward
}

update :: proc()
{
    dt := cast(f32)rl.GetFrameTime();

    SPEED : f32 : 10.0;
    ROTSPEED : f32 : 4.0;


    for &t in g_vars.player.transform
    {
        r, u, f := getDirections(t.rot)

        yaw := linalg.quaternion_angle_axis(dt * ROTSPEED, vec3{0, 1, 0})
        yawNeg := linalg.quaternion_angle_axis(-dt * ROTSPEED, vec3{0, 1, 0})
        pitch := linalg.quaternion_angle_axis(dt * ROTSPEED, vec3{1, 0, 0})
        pitchNeg := linalg.quaternion_angle_axis(-dt * ROTSPEED, vec3{1, 0, 0})

        if rl.IsKeyDown(.W) do t.pos -= f * dt * SPEED;
        if rl.IsKeyDown(.S) do t.pos += f * dt * SPEED;
        if rl.IsKeyDown(.D) do t.pos += r * dt * SPEED;
        if rl.IsKeyDown(.A) do t.pos -= r * dt * SPEED;

        if rl.IsKeyDown(.I) do t.rot *= pitchNeg;
        if rl.IsKeyDown(.J) do t.rot *= yaw;
        if rl.IsKeyDown(.K) do t.rot *= pitch;
        if rl.IsKeyDown(.L) do t.rot *= yawNeg;
    }

}

render :: proc()
{
    rl.BeginDrawing();
    defer rl.EndDrawing();

    rl.ClearBackground({0, 64, 96, 0});

    rl.BeginMode3D(g_vars.cam)
    defer rl.EndMode3D()
    defer rl.DrawFPS(4, 4)

    draw()

}
