extends Node2D


func reset_scene():
	get_tree().change_scene("res://scenes/Main.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_node("Player").reset()
