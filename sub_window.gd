# next: need to make minus button and a taskbar that you can minmize and maximize from.
# after that: draggable sides.

#color 2: #a5cef7

extends Node2D
class_name SubWindow


var drag_offset := Vector2(0,0)
var drag := false
var stretch := false

var stretch_side = null

var title: String:
	get:
		return title
	set(value):
		title = value
		$Title.set_text(title)

@export var window_big_sprite: Texture2D
@export var window_min_sprite: Texture2D

@export var default_window_size := Vector2(0,0)

var minimum_window_size := Vector2(0,0)#look at this again
var prev_window_pos := Vector2(0,0)
var prev_window_size : Vector2

var maximized := false:
	get:
		return maximized
	set(value):
		maximized = value
		$BoxDragButton.set_disabled(!$BoxDragButton.disabled)
		if value:
			window_size = get_viewport_rect().size
			$MaxButton.texture_normal = window_min_sprite
			prev_window_pos = position
			position = Vector2(0,0)
			$BGColorRect/MarginContainer3/TopGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_ARROW
			$BGColorRect/MarginContainer2/LeftGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_ARROW
			$BGColorRect/MarginContainer4/BottomGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_ARROW
			$BGColorRect/MarginContainer/RightGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_ARROW
			
		else:
			window_size = prev_window_size
			$MaxButton.texture_normal = window_big_sprite
			position = prev_window_pos
			$BGColorRect/MarginContainer3/TopGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_VSIZE
			$BGColorRect/MarginContainer2/LeftGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_HSIZE
			$BGColorRect/MarginContainer4/BottomGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_VSIZE
			$BGColorRect/MarginContainer/RightGrabber.mouse_default_cursor_shape = Input.CursorShape.CURSOR_HSIZE
			
@onready var window_size:
	get:
		return window_size
	set(value):
		prev_window_size = $BGColorRect.size
		
		value.x = clamp(value.x,minimum_window_size.x,get_viewport_rect().size.x)
		value.y = clamp(value.y,minimum_window_size.y,get_viewport_rect().size.y)
		
		window_size = value
		
		$BGColorRect/TopRect.size.x=value.x-2
		
		$XButton.position.x = value.x - $XButton.size.x - 3
		$MaxButton.position.x = $XButton.position.x - $MaxButton.size.x - 3
		#here is where to add the minus_button, also update the dragbutton excess amount
		
		$BoxDragButton.size.x = $BGColorRect/TopRect.size.x-40
		
		$BGColorRect.size = value

signal close_requested
#signal minimize_requested
#signal resize_requested
#signal downsize_requested
#signal maximize_requested

func _ready() -> void:
	Input.use_accumulated_input=false
	#DisplayServer.cursor_set_shape(DisplayServer.CURSOR_HSIZE)
	minimum_window_size = $BGColorRect.size
	
	connect("close_requested", _close_self)
	#for child in $BGColorRect.get_children():
		#if child.name == "TopRect" or child.name == "SubViewport":
			#pass
		#else:
			#child.connect("mouse_entered", _on_hover_stretch)
			#child.connect("mouse_exited", _on_leave_hover_stretch)
			#child.connect("gui_input", _on_gui_input)
	window_size = $BGColorRect.size
	$BoxDragButton.set_focus_mode(Control.FOCUS_NONE)

func _process(delta: float) -> void:
	
	if drag:
		position = get_global_mouse_position()-drag_offset
	#print(Engine.get_process_frames()%10)
	

func _on_close_button_pressed() -> void:
	close_requested.emit()
func _close_self() -> void:
	hide()
	queue_free()

func _on_max_button_pressed() -> void:
	maximized = !maximized
	$MaxButton.set_focus_mode(Control.FOCUS_NONE)

func _on_box_drag_button_down() -> void:
	get_parent().move_child(self,-1)
	drag_offset = get_global_mouse_position()-position
	drag = true#should also bump the window to the top of the stack.


func _on_box_drag_button_up() -> void:
	drag = false


func _on_hover_stretch() -> void:
	if maximized or stretch:
		return
	else:
		stretch = true
		stretch_side = get_viewport().gui_get_hovered_control()


func _on_leave_hover_stretch() -> void:
	if maximized:
		return
	elif !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		stretch = false
		stretch_side = null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			get_parent().move_child(self,-1)
			if stretch_side && (Input.get_current_cursor_shape()==Input.CursorShape.CURSOR_VSIZE or Input.get_current_cursor_shape()==Input.CursorShape.CURSOR_HSIZE):
				match stretch_side.name:
					"TopGrabber":
						var prev_pos_y = position.y
						var mouse_pos_y = get_global_mouse_position().y
						var delta_y = prev_pos_y - mouse_pos_y
						var pre_clamp_window_size = Vector2(window_size);
						
						# This value gets clamped, so we need to track how much it got clamped by
						window_size.y += delta_y
						
						if(pre_clamp_window_size.y + delta_y != window_size.y):
							# A clamp occurred, measure the difference, and apply the movement to the position
							var difference = (window_size.y - (pre_clamp_window_size.y + delta_y));
							position.y = mouse_pos_y - difference; 
						else:
							position.y = mouse_pos_y;
					"LeftGrabber":
						var prev_pos_x = position.x
						var mouse_pos_x = get_global_mouse_position().x
						var delta_x = prev_pos_x - mouse_pos_x
						var pre_clamp_window_size = Vector2(window_size);
						
						# This value gets clamped, so we need to track how much it got clamped by
						window_size.x += delta_x
						
						if(pre_clamp_window_size.x + delta_x != window_size.x):
							# A clamp occurred, measure the difference, and apply the movement to the position
							var difference = (window_size.x - (pre_clamp_window_size.x + delta_x));
							position.x = mouse_pos_x - difference; 
						else:
							position.x = mouse_pos_x;
					"BottomGrabber":
						window_size.y = get_local_mouse_position().y
					"RightGrabber":
						window_size.x = get_local_mouse_position().x
					_:
						pass
# things to do: bitflip, a ram visualizer, 
