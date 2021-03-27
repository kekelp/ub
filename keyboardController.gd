extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var defaultfrog_count: int = 945

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	if Input.is_action_just_pressed("stance_punch"):
#		self.owner.get_node("PuppetMaster/baj").switch_to_stance_punching()
#	if Input.is_action_just_pressed("stance_grab"):
#		self.owner.get_node("PuppetMaster/baj").switch_to_stance_grabbing()
	if Input.is_action_just_pressed("ui_home"):
		self.owner.get_node("PuppetMaster").spawn_baj("defaultfrog #"+str(defaultfrog_count))
		defaultfrog_count +=1
#if Input.is_action_just_pressed("stance_rasengan"):
#		self.owner.get_node("PuppetMaster/baj").switch_to_stance_rasengan()

			

