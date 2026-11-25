
extends CharacterBody3D

const SPEED := 6.0
const JUMP_VELOCITY := 4.5
const GRAVITY := 9.8

var move_direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
    apply_gravity(delta)
    handle_movement()
    handle_jump()

    move_and_slide()


func apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= GRAVITY * delta


func handle_movement() -> void:
    move_direction = Input.get_vector(
        "ui_left",
        "ui_right",
        "ui_up",
        "ui_down"
    )

    var direction := Vector3(
        move_direction.x,
        0.0,
        move_direction.y
    )

    if direction.length() > 0.0:
        direction = direction.normalized()

        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0.0, SPEED)
        velocity.z = move_toward(velocity.z, 0.0, SPEED)


func handle_jump() -> void:
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY
