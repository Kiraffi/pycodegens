package game

vec3 :: [3]f32
vec4 :: [4]f32
quat :: quaternion128

EntityTypes :: enum
{
    PlayerType,
}

VelocityComponent :: struct
{
    vel : vec4,
}

TransformComponent :: struct
{
    pos : vec4,
    rot : quat,
    scale : vec4,
}

OffsetComponent :: struct
{
    pos : vec4,
}

PlayerEntity :: struct
{
    transform : [dynamic] TransformComponent,
    vel : [dynamic] VelocityComponent,
    offset : [dynamic] OffsetComponent,
}

