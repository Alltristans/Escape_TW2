extends Area3D

func interact(player):
	if player.inventory["NaCl"]:
		print("YOU ESCAPED! YOU WIN!")
		get_tree().quit()
	else:
		print("You need to craft NaCl first before escaping!")
