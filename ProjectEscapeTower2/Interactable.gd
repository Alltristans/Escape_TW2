extends Area3D

@export var item_name: String = "Na"

func interact(player):
	if player.inventory.has(item_name):
		player.inventory[item_name] = true
		Director.notify_sound_event(10.0) # Picking up item makes noise
		queue_free()
