
extends Node3D

const TREE_COUNT := 35
const ROCK_COUNT := 25
const DINOSAUR_COUNT := 4

const PLAYER_SCENE := preload("res://Player.tscn")
const DINOSAUR_SCENE := preload("res://Dinosaur.tscn")

var rng := RandomNumberGenerator.new()


func _ready() -> void:
    rng.randomize()

    setup_ground()
    generate_trees()
    generate_rocks()
    spawn_player()
    spawn_dinosaurs()


func setup_ground() -> void:
    var ground_mesh: MeshInstance3D = $Ground/GroundMesh

    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.18, 0.38, 0.12)
    material.roughness = 1.0

    ground_mesh.material_override = material


func spawn_player() -> void:
    var player := PLAYER_SCENE.instantiate()

    player.name = "Player"
    player.position = Vector3(0, 0.05, 0)

    add_child(player)

    var player_camera: Camera3D = player.get_node("Camera3D")
    player_camera.make_current()


func spawn_dinosaurs() -> void:
    for i in range(DINOSAUR_COUNT):
        var dinosaur := DINOSAUR_SCENE.instantiate()

        dinosaur.name = "Dinosaur_%d" % i

        var x := rng.randf_range(-30.0, 30.0)
        var z := rng.randf_range(-30.0, 30.0)

        if Vector2(x, z).length() < 12.0:
            x += 15.0

        dinosaur.position = Vector3(x, 0.05, z)

        add_child(dinosaur)


func generate_trees() -> void:
    for i in range(TREE_COUNT):
        var tree := Node3D.new()
        tree.name = "AncientTree_%d" % i

        tree.position = Vector3(
            rng.randf_range(-45.0, 45.0),
            0.0,
            rng.randf_range(-45.0, 45.0)
        )

        var trunk := MeshInstance3D.new()
        var trunk_mesh := CylinderMesh.new()

        trunk_mesh.top_radius = 0.25
        trunk_mesh.bottom_radius = 0.45
        trunk_mesh.height = 3.5

        trunk.mesh = trunk_mesh
        trunk.position.y = 1.75

        var trunk_material := StandardMaterial3D.new()
        trunk_material.albedo_color = Color(0.28, 0.16, 0.08)
        trunk.material_override = trunk_material

        tree.add_child(trunk)

        var leaves := MeshInstance3D.new()
        var leaves_mesh := SphereMesh.new()

        leaves_mesh.radius = 2.0
        leaves_mesh.height = 4.0

        leaves.mesh = leaves_mesh
        leaves.position.y = 4.2

        var leaves_material := StandardMaterial3D.new()
        leaves_material.albedo_color = Color(
            rng.randf_range(0.08, 0.18),
            rng.randf_range(0.25, 0.42),
            0.06
        )

        leaves.material_override = leaves_material

        tree.add_child(leaves)
        add_child(tree)


func generate_rocks() -> void:
    for i in range(ROCK_COUNT):
        var rock := MeshInstance3D.new()
        rock.name = "AncientRock_%d" % i

        var rock_mesh := SphereMesh.new()
        var size := rng.randf_range(0.5, 1.5)

        rock_mesh.radius = size
        rock_mesh.height = size * 1.5

        rock.mesh = rock_mesh

        rock.position = Vector3(
            rng.randf_range(-45.0, 45.0),
            size * 0.5,
            rng.randf_range(-45.0, 45.0)
        )

        rock.scale = Vector3(
            rng.randf_range(1.0, 2.0),
            rng.randf_range(0.7, 1.2),
            rng.randf_range(1.0, 2.0)
        )

        var rock_material := StandardMaterial3D.new()
        rock_material.albedo_color = Color(0.35, 0.34, 0.30)
        rock_material.roughness = 1.0

        rock.material_override = rock_material

        add_child(rock)
