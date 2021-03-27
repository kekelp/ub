extends RigidBody2D



var force = Vector2(0,0)

var script_force_multiplier = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	$g.rotation = -self.rotation
#	$name.position = self.gl

func _integrate_forces(_state):
	var total_force = (force) * script_force_multiplier
	set_applied_force(total_force)
