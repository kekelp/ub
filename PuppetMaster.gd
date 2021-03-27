extends Node2D

const BAJ = preload("res://baj/baj.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	call_deferred("spawn_baj", "defaultfrog #934")
#	call_deferred("spawn_baj", "defaultfrog #722")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_baj(name: String):
	var baj1 = BAJ.instance()
	self.add_child(baj1)
	var left_x = self.get_parent().get_node("Arena").get_node("spawn-left").global_position.x
	var right_x = self.get_parent().get_node("Arena").get_node("spawn-right").global_position.x
	var y = self.get_parent().get_node("Arena").get_node("spawn-left").global_position.y
	randomize()
	baj1.global_position = Vector2( rand_range(left_x, right_x)  , y)
	baj1.set_color(random_npc_color())
	baj1.set_name(name)
	return baj1

func random_npc_color():
	var hue = rand_range(0.0, 1.0)
	return Color.from_hsv(hue, 0.58, 0.7)

func random_good_color():
	var hue = rand_range(0.0, 1.0)
	return Color.from_hsv(hue, 0.8, 0.85)
