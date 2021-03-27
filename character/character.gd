extends Node2D

enum CONTROL_MODE {kbm, gamepad, kbm_or_gamepad, ai, network}
export(CONTROL_MODE) var control_mode:int = CONTROL_MODE.kbm_or_gamepad
# state

#enum STANCE {punching, grabbing, rasengan}
enum STANCE {punching, grabbing}
enum STATE {swinging, throwing1, throwing2}
enum MOUSE_INPUT {attack, withdraw}

var n_stances = 2

export var stance: int
var mouse_input: int = 1
var mouse_input2: bool = false
var state = STATE.swinging
var being_grabbed: bool = false
var falling_from_throw: bool = false

var moving_right: bool = false
var moving_left: bool = false
var moving_up: bool = false
var moving_down: bool = false

var enemy_grabbing_hand = null

var body_getting_grabbed_by_self = null

var airborne = false

export var base_color: Color = Color(0.8, 0.7, 3.0)

export var base_name = "defaultfrog #12"

# parameters

var dead = false
var respawn_timer = 0
var respawn_wait_time = 1.2

var global_throw_nerf = 0.9

var release1_wait = 0.2
var release2_wait = 0.4

var falling_from_throw_wait = 0.3

var p_to_damage_coeff_FALL = 0.75

var p_to_damage_coeff = 0.45
var maxopacitydamage = 500

var extra_kick_coeff = 0.35
var extra_grabkick_coeff = 0.95


var x_dirmod = 0.0
var x_max_speed = 800
var x_max_walk_force = 1500000
var x_damp = 950

var y_dirmod = 0.0
var y_max_speed = 600
var y_min_speed = 300
var y_max_walk_force = 800000
var y_damp = 950

var max_punch_recoil_force = 80

var hand_base_mass = 2.0
var hand_off_arc_p_boost = 5.0
#var real_punch_min_speed = 120
var real_punch_min_speed = 500

var max_punch_force = 20.0


var aim_coeff = 5.0

var optimal_jump_delta = 115
var airborne_excess_height = 1.4

var max_hand_speed = 270
var magical_damp_gamma = 45.0

var aim_damp_mod = 0.3
var charge_damp_mod = 2.0
var wdraw_damp_mod = 0.8

var hand_optimal_energy = 180000
var accel_gamma = 0.05



const YELLOW_BANG = preload("res://vfx/yellow-bang.tscn")


func random_npc_color():
	var hue = rand_range(0.0, 1.0)
	return Color.from_hsv(hue, 0.58, 0.7)

func random_good_color():
	var hue = rand_range(0.0, 1.0)
	return Color.from_hsv(hue, 0.8, 0.85)
# Called when the node enters the scene tree for the first time.
func _ready():
	# enum STANCE {punching, grabbing, rasengan}
	switch_to_stance()
	self.set_color(base_color)
	self.set_name(base_name)
	
	$hand.add_collision_exception_with($body)
#	$left_hand.add_collision_exception_with($body)
#	$hand.add_collision_exception_with($left_hand)


# vars
var fall_timer = 0

var almost_zero = 0.00001
var damage_taken: float = almost_zero
#
#var target: Node2D
var target_b_pos: Vector2
var elapsed_time = 0

var direction: float = 0

var release_timer = 0

var second_last_height = 0
var last_height = 0
var height = 0
var highest_height = 0
var current_jump_height = 0
var current_ground_level = 0

onready var arena = get_tree().get_nodes_in_group("arena")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	elapsed_time += delta
	
	# jump adjustment
	# remember that y axis is inverted
	second_last_height = last_height
	last_height = height
	height = $body.global_position.y
	
#	Engine.time_scale = 0.5

	
#	if (second_last_height > last_height && height > last_height):
#		current_jump_height = (last_height)
#		var excess_jump = (current_ground_level - current_jump_height) - optimal_jump_delta
#		var hbounce = 0.2 + 0.8 * exp(-excess_jump/(optimal_jump_delta*25))
#		if(excess_jump > 0):
#			$body.bounce = hbounce
#		else:
#			$body.bounce = 1.0
#	elif (second_last_height < last_height && height < last_height):
#		current_ground_level = last_height
#
#	if abs(current_ground_level - current_jump_height) /optimal_jump_delta > airborne_excess_height: self.airborne = true
#	else: self.airborne = false
#	print(self, " ", airborne)

	# hand physics

	# punch state analysis (right hand)
#	target_b_pos = get_viewport().get_mouse_position()

	var return_vec: Vector2 = $body.global_position - $hand.global_position
	
	var target_vec = Vector2(0,0)
	target_vec =  target_b_pos -$hand.global_position
	
	var outwards: bool = false
	if $hand.linear_velocity.dot(return_vec) < 0: outwards = true
	
	var towards_enemy: bool = false
	if $hand.linear_velocity.dot(target_vec) > 0: towards_enemy = true

#	if self != self.get_parent().get_node("baj"):


	$hand.offensive_arc = towards_enemy && outwards
	if $hand.offensive_arc == true:
		$hand.mass = hand_base_mass * hand_off_arc_p_boost
		$hand.script_force_multiplier = hand_off_arc_p_boost
#		$hand.get_node("g/Sprite").modulate = Color("#ff0000")
	else:
		$hand.mass = hand_base_mass
		$hand.script_force_multiplier = 1.0
#		$hand.get_node("g/Sprite").modulate = Color("#00ff00")
	
	var aimed_vec: Vector2
#	aimed_vec = (return_vec.normalized() + target_vec.normalized()*aim_coeff).normalized() * return_vec.length()
	var damp_force = Vector2(0,0)
	
	########################## new
	var tangent_versor = return_vec.normalized().rotated(PI/2)
	var return_versor = return_vec.normalized()
	var radial_velocity = $hand.linear_velocity.dot(return_versor) 
	var tangent_velocity = $hand.linear_velocity.dot(tangent_versor) 

	var oscillator_force = 45.0
	var drag_amount = 3.5
	var punch_force = 600 *1000
#	var exp_punch_force = 300 * 1000
	var exp_punch_force = 0
	var punch_exp_l = 45
#	var oscillator_force = 170.0
#	var drag_amount = 9.0
#	var punch_force = 7000
	$hand.punch_force = Vector2(0,0)
	var oscill_xn: float = 200*pow((return_vec.length()/200),1.5)

	# position drag
#	var drag_mod = smoothstep(0, 250, return_vec.length())
	var drag_mod = 1
	$hand.global_position += return_vec*drag_amount*delta *drag_mod


#		# use new_vec instead of target_vec? no
	var new_vec: Vector2 = target_b_pos - $body.global_position 
	if mouse_input == MOUSE_INPUT.attack:
		var att_str 
		if towards_enemy == true && outwards == true:
			att_str = punch_force + exp_punch_force*exp(-(return_vec.length())/punch_exp_l)
		else:
			att_str = punch_force
		$hand.punch_force += new_vec.normalized()*att_str* delta

	elif mouse_input2 == true:
		# pull
		var att_str 
		att_str = punch_force
		$hand.punch_force += -new_vec.normalized()*att_str* delta

	$hand.punch_force += oscill_xn* return_vec.normalized() *oscillator_force

##########################

	if state == STATE.swinging:
#		# punch state = striking
#		if towards_enemy == true && outwards == true:
#			$hand.punch_force = (return_vec)* max_punch_force
#		# punch state = withdraw
#		elif towards_enemy == false && outwards == false:
#	#		aimed_vec = (return_vec + target_vec*aim_coeff*(-1.0)).normalized() * return_vec.length()
#			var excess_speed = ($hand.linear_velocity.length() - max_hand_speed)
#			if excess_speed > 0:
#				damp_force = -$hand.linear_velocity.normalized() * excess_speed *magical_damp_gamma*wdraw_damp_mod	
#			$hand.punch_force = (return_vec)* max_punch_force * 2.0 + damp_force
#		# punch state = charge 
#		elif towards_enemy == false && outwards == true:
#			var excess_speed = ($hand.linear_velocity.length() - max_hand_speed)
#			if excess_speed > 0:
#				damp_force = -$hand.linear_velocity.normalized() * excess_speed *magical_damp_gamma*charge_damp_mod
#			$hand.punch_force = (return_vec)* max_punch_force + damp_force
#		# punch state = aim
#		elif towards_enemy == true && outwards == false:
#
#			var excess_speed = ($hand.linear_velocity.length() - max_hand_speed)
#			if excess_speed > 0:
#				damp_force = -$hand.linear_velocity.normalized() * excess_speed *magical_damp_gamma*aim_damp_mod
			# extra_aim_force (acceleration)
#			var extra_aim_force = aimed_vec.normalized() * (70000) *accel_gamma
#			$hand.punch_force = (aimed_vec)* max_punch_force + damp_force + extra_aim_force

		#remember gravity scale 16
		pass


		
#	elif state == STATE.throwing1:
#			$hand.punch_force = (return_vec)* max_punch_force*2.5 + (return_vec).normalized() * max_punch_force*550.5
#	elif state == STATE.throwing2:
#			var excess_speed = ($hand.linear_velocity.length() - max_hand_speed)
#			if excess_speed > 0:
#				damp_force = -$hand.linear_velocity.normalized() * excess_speed *magical_damp_gamma*wdraw_damp_mod	
#			$hand.punch_force = (return_vec)* max_punch_force * 0.8 + damp_force

# hit arena
#	if stance == STANCE.grabbing:
#		$hand.collision_mask = 6 # remove collisions with bodies (finger does it)
#	else:
#		$hand.collision_mask = 7
#	if stance == STANCE.grabbing && state == STATE.swinging:
#		$hand/fingers.collision_mask = 15 # enable fingers
#	else:
#		$hand/fingers.collision_mask = 0 # disable fingers

#don't hit arena ##### DOUBLE CHECK THE 2 #########
	if stance == STANCE.grabbing:
		$hand.collision_mask = 2 # remove collisions with bodies (finger does it)
	else:
		$hand.collision_mask = 3
	if stance == STANCE.grabbing && state == STATE.swinging:
		$hand/fingers.collision_mask = 11 # enable fingers
	else:
		$hand/fingers.collision_mask = 0 # disable fingers

		
		
	if state == STATE.throwing1:
		release_timer += delta
		if release_timer >= release1_wait:
			release1(body_getting_grabbed_by_self)
	if state == STATE.throwing2:
		release_timer += delta
		if release_timer >= release2_wait:
			release2(body_getting_grabbed_by_self)
	
	if self.falling_from_throw == true:
		fall_timer += delta
		if fall_timer >= falling_from_throw_wait:
			self.falling_from_throw = false
			fall_timer = 0
	
	#body physics
	$body.force = Vector2(0,0)
	
	if (self.being_grabbed == true):
		# dragged by enemy grabbing hand
		var grab_return_vec = enemy_grabbing_hand.global_position - $body.global_position
		if enemy_grabbing_hand.owner.airborne == true:
			$body.force += (grab_return_vec*750 - $body.linear_velocity.normalized() * 5)*global_throw_nerf * 0.05
			print("denied! ")
		else:
			$body.force += (grab_return_vec*750 - $body.linear_velocity.normalized() * 5) *global_throw_nerf
		
		# self pull
		var holding_on_return_vec = enemy_grabbing_hand.global_position - enemy_grabbing_hand.owner.get_node("body").global_position
		if enemy_grabbing_hand.owner.airborne == true:
			enemy_grabbing_hand.owner.get_node("body").force += (holding_on_return_vec*750 - $body.linear_velocity.normalized() * 10) *0.3
		else:
			enemy_grabbing_hand.owner.get_node("body").force += (holding_on_return_vec*750 - $body.linear_velocity.normalized() * 10) *0.05
#	print("holding on... force ", -grab_return_vec*750 )
#			print(enemy_grabbing_hand.owner, enemy_grabbing_hand.owner.airborne == true)
			
	else:
		# walking
		# x

		var x_force = 0
		var y_force = 0
		if moving_left:
			x_dirmod = -1
		elif moving_right:
			x_dirmod = 1
		else:
			x_dirmod = 0
			
		var x_braking = sign($body.linear_velocity.x * x_dirmod)
		var x_brake_mod = 1
		if x_braking == -1: x_brake_mod = 2.2
		
		if abs($body.linear_velocity.x) < x_max_speed:
			x_force += (x_max_speed - abs($body.linear_velocity.x))/x_max_speed * x_max_walk_force * delta * x_dirmod * x_brake_mod
		if abs($body.linear_velocity.x) > x_max_speed:
			x_force -= ($body.linear_velocity.x - x_max_speed)* delta * x_damp  
		
		# y
		

#
#		var too_slow = max(y_min_speed - abs($body.linear_velocity.y), 0)/y_max_speed
#
#		if Input.is_action_pressed("move_up"):
##			y_dirmod = -1
#			$body.physics_material_override.bounce = 10.0 + too_slow*500000
#			print(too_slow)
#		elif Input.is_action_pressed("move_down"):
#			$body.physics_material_override.bounce = 0.7
##			y_dirmod = 1
#		else:
#			$body.physics_material_override.bounce = 1

#		if abs($body.linear_velocity.y) < y_max_speed:
#			y_force += (y_max_speed - abs($body.linear_velocity.y))/y_max_speed * y_max_walk_force * delta * y_dirmod
		if abs($body.linear_velocity.y) > y_max_speed:
			y_force -= ($body.linear_velocity.y - y_max_speed)* delta * y_damp  

			
		$body.force += Vector2(x_force, y_force)
#		print($body.linear_velocity.y)

		
#func _input(event):
#	if event is InputEventMouseButton and event.pressed:
#		if event.button_index == BUTTON_WHEEL_UP :
#			self.stance = (self.stance + 1)%n_stances
#			switch_to_stance()
#			print(stance)
#		if event.button_index == BUTTON_WHEEL_DOWN:
#			self.stance = (self.stance + 1)%n_stances
#			switch_to_stance()
#			print(stance)
#	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
#		if event.is_pressed():  # Mouse button down.
#			mouse_input = MOUSE_INPUT.attack
#		elif not event.is_pressed():  # Mouse button released.
#			mouse_input = MOUSE_INPUT.withdraw
#	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
#		if event.is_pressed():  # Mouse button down.
#			mouse_input2 = true
#		elif not event.is_pressed():  # Mouse button released.
#			mouse_input2 = false


func _process(delta):
	if self.dead == false:
		if $body.global_position.y < arena.get_node("die_top").global_position.y:
			self.die()
		elif $body.global_position.y > arena.get_node("die_bottom").global_position.y:
			self.die()
		elif $body.global_position.x < arena.get_node("die_left").global_position.x:
			self.die()
		elif $body.global_position.x > arena.get_node("die_right").global_position.x:
			self.die()
		
#	if dead == true:
#		respawn_timer += delta
#		if respawn_timer >= respawn_wait_time:
#			print("???????")
#			call_deferred("respawn")
#			respawn_timer = 0

func die():
	print(" dead on my screen ")
#	self.queue_free()
#	respawn()
	self.dead = true
	$RespawnTimer.start(respawn_wait_time)
	respawn_timer = 0



# get punched. collider is the incoming hand 
# or hit the ground
func _on_body_body_entered(collider):
	if collider.has_method("be_a_hand"):
		var incoming_p = collider.mass * collider.linear_velocity
		self.damage_taken += sqrt(incoming_p.length())* p_to_damage_coeff * 0.2
		# extra kick
		if collider.offensive_arc == true && collider.linear_velocity.length() > real_punch_min_speed:
			self.damage_taken += sqrt(incoming_p.length())* p_to_damage_coeff * 0.8
			$body.apply_central_impulse($body.linear_velocity *0.1*extra_kick_coeff*damage_taken)
		
			var yellow1 = YELLOW_BANG.instance()
			self.add_child(yellow1)
			yellow1.global_position = collider.global_position
			
		update_damage_debuff()
#		print(" punch damage" , sqrt(incoming_p.length())* p_to_damage_coeff)
	elif collider.has_method("be_a_static_arena_part"):
		# bounce adjust
		var too_slow = max(y_min_speed - abs($body.linear_velocity.y), 0)/y_max_speed
		if moving_up:
			$body.apply_central_impulse(Vector2(0,-5000))
			print($body.physics_material_override.bounce)
		elif moving_down:
			$body.apply_central_impulse(Vector2(0,900))

		# get hurt if being thrown
		if self.falling_from_throw == true:
			var impact_p = $body.mass * $body.linear_velocity
			self.damage_taken += sqrt(impact_p.length())* p_to_damage_coeff_FALL
#			print("fall damage ",sqrt(impact_p.length())* p_to_damage_coeff_FALL)
			if ($body.linear_velocity.length() > real_punch_min_speed*2):
				var yellow1 = YELLOW_BANG.instance()
				print(self)
				print(self.owner)
				self.add_child(yellow1)
				yellow1.global_position = $body.global_position
			update_damage_debuff()
			

func big_booma(pos: Position2D):
	var yellow1 = YELLOW_BANG.instance()
	self.owner.add_child(yellow1)
	yellow1.global_position = pos


func update_damage_debuff():
	var _inverse_damage = 1.0/(damage_taken)
#	var alpha = 0.6 * min((damage_taken/maxopacitydamage),1 )
#	$body.get_node("RedSprite").modulate = Color(0.7, 0.0, 0.0, alpha)
	var white =  Color( 1, 1, 1, 1 )
	var namealpha = 0.9 * min((damage_taken/maxopacitydamage),1 )
	var newred_alpha = Color( 0.86, 0.08, 0.24, namealpha )
	$body/g/name.modulate = white.blend(newred_alpha)



# for when the fingers hit something. collider is the guy getting grabbed
func _on_fingers_body_entered(collider):
	if collider.get_name() == "body":
		if $body != collider:
			grab(collider)
#			print("i grabbed the streamer lol", collider, collider.get_name())
	if collider.get_name() == "hand":
		if $hand != collider:
			# judo move
			pass


func grab(body_getting_grabbed: RigidBody2D):
	body_getting_grabbed.owner.being_grabbed = true
	body_getting_grabbed.owner.enemy_grabbing_hand = $hand
	body_getting_grabbed.add_collision_exception_with($body)
	body_getting_grabbed.owner.get_node("hand").add_collision_exception_with($body)
	self.body_getting_grabbed_by_self = body_getting_grabbed
	$hand/g/Sprite.play("grab_grip")
	self.release_timer = 0
	self.state = STATE.throwing1

func release1(body_getting_released: RigidBody2D):
	body_getting_released.owner.being_grabbed = false
	body_getting_released.owner.enemy_grabbing_hand = null
	# throw extra kick
	if self.airborne == false:
		pass
		body_getting_released.apply_central_impulse($body.linear_velocity.normalized()*1000.0 *body_getting_released.owner.extra_grabkick_coeff *body_getting_released.owner.damage_taken* 0.004*global_throw_nerf)
	body_getting_released.owner.falling_from_throw = true
	self.release_timer = 0
	self.state = STATE.throwing2

		
func release2(body_getting_released: RigidBody2D):
	body_getting_released.remove_collision_exception_with($body)
	body_getting_released.owner.get_node("hand").remove_collision_exception_with($body)
	self.body_getting_grabbed_by_self = null
	self.state = STATE.swinging
	$hand/g/Sprite.play("grab")
	
func switch_to_stance_punching():
	self.stance = STANCE.punching
	$hand/g/Sprite.play("punch")

func switch_to_stance_grabbing():
	self.stance = STANCE.grabbing
	$hand/g/Sprite.play("grab")
	
func switch_to_stance_rasengan():
	self.stance = STANCE.rasengan
	$hand/g/Sprite.play("rasengan")
	
func switch_to_stance():
	if self.stance == STANCE.punching:
		self.switch_to_stance_punching()
	if self.stance == STANCE.grabbing:
		self.switch_to_stance_grabbing()
#	if self.stance == STANCE.rasengan:
#		self.switch_to_stance_rasengan()


func set_color(color):
	self.base_color = color
	$body/Sprite.modulate = color
	$hand/g/Sprite.modulate = color.lightened(0.5)
	
func set_name(name):
	self.base_name = name
	$body/g/name.text = name

func respawn():
	var left_x = arena.get_node("spawn-left").global_position.x
	var right_x = arena.get_node("spawn-right").global_position.x
	var y = arena.get_node("spawn-left").global_position.y
	randomize()
	$body.global_position = Vector2( rand_range(left_x, right_x)  , y)
	$body.linear_velocity = Vector2(0,0)
	$hand.global_position = $body.global_position + $hand.rest_pos
	$hand.linear_velocity = Vector2(0,0)
	self.damage_taken = almost_zero
	self.dead = false
	self.update_damage_debuff()


func _on_RespawnTimer_timeout():
	respawn() # Replace with function body.

func get_character_data():
	var c_data = {}
	c_data.name = ($body/g/name.text)
	c_data.color = Color($body/Sprite.modulate)
	return c_data.duplicate()
	
func get_character_position():
	var c_pos = {}
	c_pos.hand_pos = ($hand.global_position)
	c_pos.body_pos = ($body.global_position)
	return c_pos.duplicate()
