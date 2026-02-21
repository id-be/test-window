extends Node2D

func _ready()->void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_spawn_window()
	if Input.is_action_just_pressed("ui_cancel"):
		_spawn_real_window()

func _spawn_window() -> void:
	var base_window = preload("res://SubWindow.tscn")
	var new_window = base_window.instantiate()

	get_tree().get_root().add_child(new_window)

	new_window.global_position = get_global_mouse_position()

func _spawn_real_window() -> void:
	var base_window = preload("res://RealSubWindow.tscn")
	var new_window = base_window.instantiate()
	
	get_tree().get_root().add_child(new_window)
	new_window.position = get_global_mouse_position()
