extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	var player = get_node("../Player")
	self.connect("body_entered", player, "_on_body_entered", [self])
