extends CharacterBody3D

@export var walk_speed = 5.0
@export var run_speed = 8.0
@export var crouch_speed = 2.5
@export var mouse_sensitivity = 0.002

var current_speed = 5.0
var camera: Camera3D

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $Camera3D
	Director.player_reference = self

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	current_speed = walk_speed
	var is_running = Input.is_key_pressed(KEY_SHIFT)
	var is_crouching = Input.is_key_pressed(KEY_CTRL)
	
	if is_running:
		current_speed = run_speed
		if velocity.length() > 0.1:
			Director.add_menace(delta * 2.0)
	elif is_crouching:
		current_speed = crouch_speed
		camera.position.y = lerp(camera.position.y, 0.0, 10.0 * delta)
	else:
		camera.position.y = lerp(camera.position.y, 0.6, 10.0 * delta)

	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1
	if Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	input_dir = input_dir.normalized()
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
