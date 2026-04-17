extends Area3D

# This is the chemistry lab station where Na + Cl -> NaCl
func interact(player):
	if player.inventory["Na"] and player.inventory["Cl"]:
		if not player.inventory["NaCl"]:
			player.inventory["NaCl"] = true
			# "Proses pencampuran Na + Cl di lab menghasilkan suara yang menarik Ghost"
			Director.notify_sound_event(40.0) 
			# "Saat reaksi NaCl selesai, Menace Gauge dipaksa ke angka 100 memicu pengejaran klimaks"
			Director.trigger_final_rush()
			print("NaCl CRAFTED! FINAL RUSH! ESCAPE TO THE STAIRS!")
	else:
		print("You need Na and Cl to craft NaCl!")
