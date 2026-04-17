extends CharacterBody3D

@export var patrol_speed = 3.0
@export var hunt_speed = 7.0
@export var fov_angle = 70.0
@export var view_distance = 30.0

var nav_agent: NavigationAgent3D
var player: CharacterBody3D
var patrol_points = []
var wait_timer = 0.0
var current_patrol_target: Vector3 = Vector3.ZERO

func _ready():
	Director.ghost_reference = self
	nav_agent = $NavigationAgent3D
	
	# Fetch Patrol Points
	var pp_node = get_node_or_null("../PatrolPoints")
	if pp_node:
		for child in pp_node.get_children():
			patrol_points.append(child.global_position)
	
	if patrol_points.is_empty():
		patrol_points.append(global_position)
		
	# Delay agent initialization until NavMesh is completely ready
	call_deferred("pick_new_patrol_point")

func pick_new_patrol_point():
	current_patrol_target = patrol_points[randi() % patrol_points.size()]
	nav_agent.target_position = current_patrol_target
	print("Ghost menuju titik patroli: ", current_patrol_target)

func _physics_process(delta):
	if not player:
		player = Director.player_reference
		return
		
	var speed = 0.0
	var state = Director.current_ghost_state
	
	check_vision_cone(delta)
	
	# Override Agent Target based on State
	if state == Director.GhostState.RELEASE:
		nav_agent.target_position = get_farthest_point()
		speed = hunt_speed
	elif state == Director.GhostState.HUNT:
		nav_agent.target_position = player.global_position
		speed = hunt_speed
	else:
		speed = patrol_speed
		
		# Simple distance check instead of relying purely on nav_agent.is_navigation_finished() 
		# which can glitch if NavMesh is incomplete.
		var dist_to_target = global_position.distance_to(current_patrol_target)
		
		if dist_to_target < 2.0 or nav_agent.is_navigation_finished():
			if wait_timer > 0:
				wait_timer -= delta
			else:
				wait_timer = randf_range(1.0, 3.0)
				pick_new_patrol_point()

	# Movement Execution
	var dir = Vector3.ZERO
	if nav_agent.is_target_reachable() or state == Director.GhostState.HUNT:
		var next_pos = nav_agent.get_next_path_position()
		dir = global_position.direction_to(next_pos)
	else:
		# Fallback movement if NavMesh fails: Direct line to target (Wall-less map)
		dir = global_position.direction_to(nav_agent.target_position)

	dir.y = 0
	dir = dir.normalized()
	
	if dir.length_squared() > 0.01:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		
		# Rotate towards movement direction gracefully
		var target_basis = Basis.looking_at(-dir, Vector3.UP)
		transform.basis = transform.basis.slerp(target_basis, 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	move_and_slide()
	
	# Death Check
	if state == Director.GhostState.HUNT and global_position.distance_to(player.global_position) < 1.5:
		print("GAME OVER! GHOST CAUGHT YOU!")
		get_tree().quit()

func check_vision_cone(delta):
	if Director.current_ghost_state == Director.GhostState.RELEASE:
		return
		
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	# Proximity
	if distance < 8.0:
		Director.add_menace(5.0 * delta)
		
	# Sight
	if distance < view_distance:
		var dir_to_player = to_player.normalized()
		var forward = -transform.basis.z
		var angle = rad_to_deg(forward.angle_to(dir_to_player))
		
		if angle < fov_angle:
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, player.global_position + Vector3.UP)
			query.exclude = [self.get_rid()]
			var result = space_state.intersect_ray(query)
			
			if result and result.collider == player:
				Director.add_menace(25.0 * delta)

func get_farthest_point() -> Vector3:
	var farthest = global_position
	var max_dist = 0.0
	for p in patrol_points:
		var d = player.global_position.distance_to(p)
		if d > max_dist:
			max_dist = d
			farthest = p
	return farthest
