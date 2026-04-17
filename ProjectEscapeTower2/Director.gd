extends Node

var menace_gauge: float = 0.0
var final_rush: bool = false
var ghost_reference: Node3D = null
var player_reference: Node3D = null

enum GhostState { PATROL, HUNT, RELEASE }
var current_ghost_state: GhostState = GhostState.PATROL

# Called when the node enters the scene tree for the first time.
func _ready():
	menace_gauge = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if final_rush:
		menace_gauge = 100.0
		current_ghost_state = GhostState.HUNT
	else:
		if current_ghost_state != GhostState.RELEASE:
			if menace_gauge >= 100.0:
				trigger_release_phase()
		else:
			# Cooldown
			menace_gauge -= delta * 5.0
			if menace_gauge <= 0:
				menace_gauge = 0
				current_ghost_state = GhostState.PATROL
				
	# Clamp score
	menace_gauge = clamp(menace_gauge, 0.0, 100.0)

func add_menace(amount: float):
	if current_ghost_state != GhostState.RELEASE:
		menace_gauge += amount
		if menace_gauge > 50.0 and current_ghost_state == GhostState.PATROL:
			current_ghost_state = GhostState.HUNT

func trigger_final_rush():
	final_rush = true

func trigger_release_phase():
	current_ghost_state = GhostState.RELEASE
	menace_gauge = 100.0

func notify_sound_event(amount: float):
	add_menace(amount)
