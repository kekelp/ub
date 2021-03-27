extends Node2D
#
#
#onready var twicil = get_node("TwiCIL")
#
#var nick = "UBA"
#var client_id = "myClient1D"
#var oauth = "oauth:txii1e1taxhibtm0ycq0go5xq0qb39"
#var channel = "umaodoroki"
#
#var active_players: Dictionary = {}
#
#func _setup_twicil():
#
#	####################
#
#  twicil.connect_to_twitch_chat()
#  twicil.connect_to_channel(channel, client_id, oauth, nick)
#
#
#
#	##################
#
#  # Enable logging (disabled by default)
#  twicil.set_logging(true)
#
#  # Add custom commands to game bot
##  twicil.commands.add("hi", self, "_command_say_hi", 0)
##  twicil.commands.add("bye", self, "_command_say_bye_to", 1)
##  twicil.commands.add("!w", self, "_command_whisper", 0)
#
#  # Add some aliases
##  twicil.commands.add_aliases("hi", ["hello", "hi,", "hello,", "bye"])
#
#  # Remove command/alias
##  twicil.commands.remove("bye")
##
##func _command_say_hi(params):
##  var sender = params[0]
##
##  twicil.send_message(str("Hello, @", sender))
##
##func _command_say_bye_to(params):
##  var sender = params[0]
##  var recipient = params[1]
##
##  twicil.send_message(str("@", recipient, ", ", sender, " says bye! TwitchUnity"))
##
##func _command_whisper(params):
##  var sender = params[0]
##
##  twicil.send_whisper(sender, "Boo!")
#
#func _ready():
#	_setup_twicil()
#	pass
#
#
#func _on_TwiCIL_message_recieved(sender, text, _emotes):
#	var words = text.split(" ")
#	if words[0].capitalize() == "Join":
#		if !active_players.has(sender):
#			var baj1 = $PuppetMaster.spawn_baj(sender)
#			active_players[sender] = baj1
#		else:
#			print(sender, " tried to join twice")
#	elif words[0].capitalize() == "Z":
#		if active_players.has(sender):
#			active_players[sender].switch_to_stance_punching()
#	elif words[0].capitalize() == "X":
#		if active_players.has(sender):
#			active_players[sender].switch_to_stance_grabbing()
#	elif words[0].capitalize() == "Quit":
#		print("same")
#		if active_players.has(sender):
#			active_players[sender].queue_free()
#			active_players.erase(sender)
