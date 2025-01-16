class_name MultiNoise
extends Resource


@export var noise_sources: Array[Noise]
@export var noise_magnitudes: Array[float]


func get_noise_3dv(vec: Vector3) -> float:
	var accum: float = 0.0
	for i:int in len(noise_sources):
		if noise_magnitudes[i]:
			accum += noise_sources[i].get_noise_3dv(vec) * noise_magnitudes[i]
	return accum
