extends RigidBody2D

var punch_force = Vector2(0,0)
var rest_pos = Vector2(98,0)

var offensive_arc:bool = false
var script_force_multiplier: float = 1.0

onready var base_y_scale = $g/Sprite.scale.y

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = rest_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$g.rotation = -self.rotation
#	$g/Sprite.rotation_degrees = 90
	var a = self.global_position
	var b = self.owner.target_b_pos
	$g/Sprite.rotation = PI/2 - atan2((b-a).x, -(b-a).y)
	if $g/Sprite.rotation > PI/2:
		$g/Sprite.scale.y = -base_y_scale
	else:
		$g/Sprite.scale.y = base_y_scale

func _integrate_forces(_state):
	var total_force = (punch_force) *script_force_multiplier 
	set_applied_force(total_force)

func be_a_hand():
	pass
