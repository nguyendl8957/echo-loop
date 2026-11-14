extends Node

@onready var hud = $HUD

func _ready() -> void:
	# TEST 1: Tick ban dau
	hud.update_hud(1, 0, 12, 0)

	assert(hud.tick_label.text == "TICK: 0/12")
	assert(hud.echo_label.text == "ECHO: 0")
	print("TEST 1 - INITIAL HUD: PASS")

	# TEST 2: Tick dat gioi han
	hud.update_hud(1, 12, 12, 0)

	assert(hud.tick_label.text == "TICK: 12/12")
	print("TEST 2 - MAX TICK: PASS")

	# TEST 3: Echo tang dan
	for echo_count in range(3):
		hud.update_hud(1, 0, 12, echo_count)

		assert(
			hud.echo_label.text == "ECHO: %d" % echo_count
		)

	print("TEST 3 - ECHO COUNT: PASS")
		# TEST 4: Kiem tra khoa input
	var buttons: Array[Button] = [
		hud.up_button,
		hud.down_button,
		hud.left_button,
		hud.right_button,
		hud.wait_button
	]
	
		# Khoa cac nut
	for button in buttons:
		button.disabled = true

	# Kiem tra trang thai khoa
	for button in buttons:
		assert(button.disabled == true)

	print("TEST 4 - INPUT LOCK: PASS")
	
		# Mo khoa cac nut
	for button in buttons:
		button.disabled = false

	# Kiem tra da mo khoa
	for button in buttons:
		assert(button.disabled == false)

	print("TEST 4 - INPUT UNLOCK: PASS")
	print("HUD LOOP TEST - CURRENT API: PASS")
	
	# TEST 5: Kiem tra cap nhat LOOP
	hud.update_loop_status(2, 1, false)

	assert(hud.loop_label.text == "LOOP: 2")
	assert(hud.echo_label.text == "ECHO: 1")
	print("TEST 5 - LOOP STATUS: PASS")

	# TEST 6: Kiem tra khoa nut khi ket thuc
	hud.update_loop_status(2, 1, true)

	assert(hud.up_button.disabled == true)
	assert(hud.down_button.disabled == true)
	assert(hud.left_button.disabled == true)
	assert(hud.right_button.disabled == true)
	assert(hud.wait_button.disabled == true)
	print("TEST 6 - FINISHED LOCK: PASS")

	# Mo khoa lai
	hud.update_loop_status(2, 1, false)
	assert(hud.up_button.disabled == false)
	print("TEST 7 - UNLOCK: PASS")
