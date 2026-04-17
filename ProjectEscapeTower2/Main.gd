extends Node3D

func _ready():
	print("Mulai Baking Navigation Mesh secara Synchronous...")
	var nav_region = $NavigationRegion3D
	if nav_region:
		nav_region.bake_navigation_mesh(false) # false means synchronous
		print("NavMesh SUDAH SELESAI di-bake!")
