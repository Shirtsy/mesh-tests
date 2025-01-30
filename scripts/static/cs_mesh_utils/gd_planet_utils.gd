extends Node


var cs_script: Resource = preload("res://scripts/static/cs_mesh_utils/PlanetUtils.cs")


func generate_planet_meshes(
        radius: float,
        marker_pos: Vector3,
        lod_dist: PackedFloat64Array,
        planet_noise: Noise
) -> Dictionary[String, Mesh]:
    return cs_script.GeneratePlanetMeshes(
            radius,
            marker_pos,
            lod_dist,
            planet_noise
    )