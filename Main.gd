
extends Node3D

const TREE_COUNT := 24
const ROCK_COUNT := 34
const GRASS_COUNT := 85
const DINOSAUR_COUNT := 4

const PLAYER_SCENE := preload("res://Player.tscn")
const DINOSAUR_SCENE := preload("res://Dinosaur.tscn")

var rng := RandomNumberGenerator.new()

var trunk_material: StandardMaterial3D
var leaf_materials: Array[StandardMaterial3D] = []
var rock_materials: Array[StandardMaterial3D] = []
var grass_materials: Array[StandardMaterial3D] = []


func _ready() -> void:
    rng.randomize()

    create_materials()
    setup_environment()
    setup_ground()
    generate_blocky_hills()
    generate_trees()
    generate_rocks()
    generate_grass()
    spawn_player()
    spawn_dinosaurs()


func create_materials() -> void:
    trunk_material = make_material(Color(0.25, 0.13, 0.06))

    leaf_materials.append(make_material(Color(0.08, 0.24, 0.06)))
    leaf_materials.append(make_material(Color(0.12, 0.32, 0.07)))
    leaf_materials.append(make_material(Color(0.18, 0.40, 0.09)))

    rock_materials.append(make_material(Color(0.30, 0.31, 0.29)))
    rock_materials.append(make_material(Color(0.39, 0.37, 0.33)))
    rock_materials.append(make_material(Color(0.24, 0.26, 0.25)))

    grass_materials.append(make_material(Color(0.20, 0.43, 0.10)))
    grass_materials.append(make_material(Color(0.28, 0.50, 0.12)))
    grass_materials.append(make_material(Color(0.14, 0.34, 0.07)))


func make_material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 1.0
    return material


func setup_environment() -> void:
    var world_environment: WorldEnvironment = $WorldEnvironment

    if world_environment.environment == null:
        world_environment.environment = Environment.new()

    var environment := world_environment.environment

    environment.background_mode = Environment.BG_SKY
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.68, 0.78, 0.92)
    environment.ambient_light_energy = 0.75

    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.tonemap_exposure = 1.1

    environment.fog_enabled = true
    environment.fog_light_color = Color(0.62, 0.73, 0.80)
    environment.fog_density = 0.008

    var sun: DirectionalLight3D = $Sun
    sun.light_energy = 1.25
    sun.shadow_enabled = true


func setup_ground() -> void:
    var ground_mesh: MeshInstance3D = $Ground/GroundMesh

    var material := make_material(Color(0.16, 0.34, 0.09))
    ground_mesh.material_override = material


func create_box(
    parent: Node,
    box_name: String,
    box_size: Vector3,
    box_position: Vector3,
    material: Material
) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = box_name

    var box_mesh := BoxMesh.new()
    box_mesh.size = box_size

    mesh_instance.mesh = box_mesh
    mesh_instance.position = box_position
    mesh_instance.material_override = material

    parent.add_child(mesh_instance)
    return mesh_instance


func generate_blocky_hills() -> void:
    for i in range(9):
        var hill := Node3D.new()
        hill.name = "VoxelHill_%d" % i

        var x := rng.randf_range(-48.0, 48.0)
        var z := rng.randf_range(-48.0, 48.0)

        hill.position = Vector3(x, 0.0, z)

        var width := rng.randf_range(7.0, 14.0)
        var height := rng.randf_range(3.0, 8.0)

        var hill_material := make_material(
            Color(
                rng.randf_range(0.18, 0.28),
                rng.randf_range(0.28, 0.38),
                rng.randf_range(0.10, 0.16)
            )
        )

        create_box(
            hill,
            "HillBase",
            Vector3(width, height, width),
            Vector3(0, height * 0.5 - 0.5, 0),
            hill_material
        )

        create_box(
            hill,
            "HillTop",
            Vector3(width * 0.65, height * 0.35, width * 0.65),
            Vector3(0, height + height * 0.12, 0),
            hill_material
        )

        add_child(hill)


func generate_trees() -> void:
    for i in range(TREE_COUNT):
        var tree := Node3D.new()
        tree.name = "VoxelTree_%d" % i

        tree.position = Vector3(
            rng.randf_range(-44.0, 44.0),
            0.0,
            rng.randf_range(-44.0, 44.0)
        )

        var trunk_height := rng.randf_range(3.0, 5.0)

        create_box(
            tree,
            "TreeTrunk",
            Vector3(0.9, trunk_height, 0.9),
            Vector3(0, trunk_height * 0.5, 0),
            trunk_material
        )

        var leaf_material: Material = leaf_materials[
            rng.randi_range(0, leaf_materials.size() - 1)
        ]

        var crown_y := trunk_height + 1.0

        create_box(
            tree,
            "LeavesLower",
            Vector3(4.2, 2.0, 4.2),
            Vector3(0, crown_y, 0),
            leaf_material
        )

        create_box(
            tree,
            "LeavesMiddle",
            Vector3(3.4, 2.0, 3.4),
            Vector3(0, crown_y + 1.4, 0),
            leaf_material
        )

        create_box(
            tree,
            "LeavesTop",
            Vector3(2.2, 1.6, 2.2),
            Vector3(0, crown_y + 2.7, 0),
            leaf_material
        )

        add_child(tree)


func generate_rocks() -> void:
    for i in range(ROCK_COUNT):
        var rock := Node3D.new()
        rock.name = "VoxelRock_%d" % i

        rock.position = Vector3(
            rng.randf_range(-45.0, 45.0),
            0.0,
            rng.randf_range(-45.0, 45.0)
        )

        var rock_material: Material = rock_materials[
            rng.randi_range(0, rock_materials.size() - 1)
        ]

        var size_x := rng.randf_range(0.8, 2.2)
        var size_y := rng.randf_range(0.6, 1.6)
        var size_z := rng.randf_range(0.8, 2.0)

        create_box(
            rock,
            "RockBase",
            Vector3(size_x, size_y, size_z),
            Vector3(0, size_y * 0.5, 0),
            rock_material
        )

        if rng.randf() > 0.45:
            create_box(
                rock,
                "RockTop",
                Vector3(size_x * 0.55, size_y * 0.45, size_z * 0.55),
                Vector3(0, size_y + size_y * 0.18, 0),
                rock_material
            )

        add_child(rock)


func generate_grass() -> void:
    for i in range(GRASS_COUNT):
        var grass := Node3D.new()
        grass.name = "GrassPatch_%d" % i

        grass.position = Vector3(
            rng.randf_range(-48.0, 48.0),
            0.0,
            rng.randf_range(-48.0, 48.0)
        )

        var grass_material: Material = grass_materials[
            rng.randi_range(0, grass_materials.size() - 1)
        ]

        var grass_height := rng.randf_range(0.25, 0.65)

        create_box(
            grass,
            "GrassBladeA",
            Vector3(0.12, grass_height, 0.12),
            Vector3(0, grass_height * 0.5, 0),
            grass_material
        )

        create_box(
            grass,
            "GrassBladeB",
            Vector3(0.12, grass_height * 0.7, 0.12),
            Vector3(0.18, grass_height * 0.35, 0.12),
            grass_material
        )

        add_child(grass)


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
