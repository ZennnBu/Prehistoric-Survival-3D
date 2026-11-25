
extends CharacterBody3D

const SPEED := 2.5
const GRAVITY := 9.8
const DETECT_DISTANCE := 18.0

var player: Node3D


func _ready() -> void:
    create_dinosaur_model()


func _physics_process(delta: float) -> void:
    find_player()
    apply_gravity(delta)
    follow_player()

    move_and_slide()


func find_player() -> void:
    if player == null:
        player = get_tree().root.find_child("Player", true, false)


func apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= GRAVITY * delta


func follow_player() -> void:
    if player == null:
        velocity.x = 0.0
        velocity.z = 0.0
        return

    var distance := global_position.distance_to(
        player.global_position
    )

    if distance > DETECT_DISTANCE:
        velocity.x = 0.0
        velocity.z = 0.0
        return

    var direction := player.global_position - global_position
    direction.y = 0.0

    if direction.length() > 1.0:
        direction = direction.normalized()

        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED

        look_at(
            Vector3(
                player.global_position.x,
                global_position.y,
                player.global_position.z
            ),
            Vector3.UP
        )
    else:
        velocity.x = 0.0
        velocity.z = 0.0


func create_dinosaur_model() -> void:
    var body := MeshInstance3D.new()
    var body_mesh := SphereMesh.new()

    body_mesh.radius = 1.0
    body_mesh.height = 2.0

    body.mesh = body_mesh
    body.position = Vector3(0.0, 1.2, 0.0)
    body.scale = Vector3(1.5, 0.8, 0.7)

    var body_material := StandardMaterial3D.new()
    body_material.albedo_color = Color(0.25, 0.42, 0.18)
    body.material_override = body_material

    add_child(body)

    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()

    head_mesh.radius = 0.55
    head_mesh.height = 1.1

    head.mesh = head_mesh
    head.position = Vector3(0.0, 1.8, -1.2)

    head.material_override = body_material

    add_child(head)

    var tail := MeshInstance3D.new()
    var tail_mesh := CylinderMesh.new()

    tail_mesh.top_radius = 0.05
    tail_mesh.bottom_radius = 0.35
    tail_mesh.height = 2.0

    tail.mesh = tail_mesh
    tail.position = Vector3(0.0, 1.0, 1.5)
    tail.rotation_degrees.x = 90.0

    tail.material_override = body_material

    add_child(tail)

    create_leg(Vector3(-0.7, 0.45, -0.5))
    create_leg(Vector3(0.7, 0.45, -0.5))
    create_leg(Vector3(-0.7, 0.45, 0.6))
    create_leg(Vector3(0.7, 0.45, 0.6))


func create_leg(leg_position: Vector3) -> void:
    var leg := MeshInstance3D.new()
    var leg_mesh := CylinderMesh.new()

    leg_mesh.top_radius = 0.18
    leg_mesh.bottom_radius = 0.25
    leg_mesh.height = 0.9

    leg.mesh = leg_mesh
    leg.position = leg_position

    var leg_material := StandardMaterial3D.new()
    leg_material.albedo_color = Color(0.2, 0.35, 0.14)

    leg.material_override = leg_material

    add_child(leg)
