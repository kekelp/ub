extends Node


# Declare member variables here. Examples:
# var a = 2
onready var pawn = self.get_parent()





func _input(event):
	if pawn.control_mode == pawn.CONTROL_MODE.kbm \
	  or pawn.control_mode == pawn.CONTROL_MODE.kbm_or_gamepad:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == BUTTON_WHEEL_UP :
				pawn.stance = (pawn.stance + 1)%pawn.n_stances
				pawn.switch_to_stance()
			if event.button_index == BUTTON_WHEEL_DOWN:
				pawn.stance = (pawn.stance + 1)%pawn.n_stances
				pawn.switch_to_stance()
		if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
			if event.is_pressed():  # Mouse button down.
				pawn.mouse_input = pawn.MOUSE_INPUT.attack
			elif not event.is_pressed():  # Mouse button released.
				pawn.mouse_input = pawn.MOUSE_INPUT.withdraw
		
		
		if Input.is_action_just_pressed("move_left"):
			pawn.moving_left = true
		if Input.is_action_just_released("move_left"):
			pawn.moving_left = false
		if Input.is_action_just_pressed("move_right"):
			pawn.moving_right = true
		if Input.is_action_just_released("move_right"):
			pawn.moving_right = false
		if Input.is_action_just_pressed("move_up"):
			pawn.moving_up = true
		if Input.is_action_just_released("move_up"):
			pawn.moving_up = false
		if Input.is_action_just_released("move_down"):
			pawn.moving_down = false
		if Input.is_action_just_released("move_down"):
			pawn.moving_down = false
			
		if event is InputEventMouseMotion:
			pawn.target_b_pos = get_viewport().get_mouse_position()
			
	if pawn.control_mode == pawn.CONTROL_MODE.gamepad \
	  or pawn.control_mode == pawn.CONTROL_MODE.kbm_or_gamepad:
#		print(event)
		if event is InputEventJoypadButton and event.pressed:
			if event.button_index == JOY_R :
				pawn.stance = (pawn.stance + 1)%pawn.n_stances
				pawn.switch_to_stance()
			if event.button_index == JOY_L:
				pawn.stance = (pawn.stance + 1)%pawn.n_stances
				pawn.switch_to_stance()
		if event is InputEventJoypadButton && event.button_index == JOY_R2:
				if event.is_pressed():  # Mouse button down.
					pawn.mouse_input = pawn.MOUSE_INPUT.attack
				elif not event.is_pressed():  # Mouse button released.
					pawn.mouse_input = pawn.MOUSE_INPUT.withdraw
		if event is InputEventJoypadMotion && event.axis == JOY_AXIS_5:
			if event.axis_value > 0.05:  # Mouse button down.
				pawn.mouse_input = pawn.MOUSE_INPUT.attack
			else:  # Mouse button released.
				pawn.mouse_input = pawn.MOUSE_INPUT.withdraw
			print(event.axis_value)


			
		if Input.is_action_just_pressed("move_left_joypad"):
			pawn.moving_left = true
		if Input.is_action_just_released("move_left_joypad"):
			pawn.moving_left = false
		if Input.is_action_just_pressed("move_right_joypad"):
			pawn.moving_right = true
		if Input.is_action_just_released("move_right_joypad"):
			pawn.moving_right = false
		if Input.is_action_just_pressed("move_up_joypad"):
			pawn.moving_up = true
		if Input.is_action_just_released("move_up_joypad"):
			pawn.moving_up = false
		if Input.is_action_just_released("move_down_joypad"):
			pawn.moving_down = false
		if Input.is_action_just_released("move_down_joypad"):
			pawn.moving_down = false
			
		var a = Input.get_action_strength("aim_right_joypad") - Input.get_action_strength("aim_left_joypad")
		var b = Input.get_action_strength("aim_down_joypad") - Input.get_action_strength("aim_up_joypad")
		var velocity = Vector2(a,b).clamped(1)
		pawn.target_b_pos = pawn.get_node("body").global_position + velocity.normalized()*100000
#		pawn.get_node("test").global_position = pawn.get_node("body").global_position + velocity.normalized()*100000
	elif pawn.control_mode == pawn.CONTROL_MODE.network:
		# do nothing and wait to be moved by rpc's
		pass
