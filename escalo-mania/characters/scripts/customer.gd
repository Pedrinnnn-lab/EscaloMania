extends Node2D

var numProducts : int
var draggable : bool = false
var is_inside_drop : int = 0
var area_ref : Array[Area2D]
var drag_offset : Vector2
var init_pos : Vector2
var finish : bool = false
@onready var textlabel = $text
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	numProducts = randi_range(1,15)
	textlabel.text = str(numProducts)

func _process(delta: float) -> void:
	#print(area_ref)
	if finish:
		position.x -= 5
	if draggable:
		if Input.is_action_just_pressed("click"):
			init_pos = global_position
			drag_offset = get_global_mouse_position() - global_position
			globalVar.is_dragging = true
		if Input.is_action_pressed("click"):
			position = get_global_mouse_position() - drag_offset
			
		elif Input.is_action_just_released("click"):
			globalVar.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_drop > 0 and not area_ref.is_empty():
				tween.tween_property(self,"global_position",area_ref[0].global_position + Vector2(0,-75),0.2).set_ease(Tween.EASE_OUT)
				timer.start()
			else:
				tween.tween_property(self,"global_position",init_pos,0.2).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_entered() -> void:
	if not globalVar.is_dragging:
		draggable = true
		scale = scale * 1.1

func _on_area_2d_mouse_exited() -> void:
	if not globalVar.is_dragging:
		draggable = false
		scale = scale / 1.1

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("drop"):
		is_inside_drop += 1
		area.modulate = globalVar.transp_green
		area_ref.push_front(area)
		print(area_ref)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("drop"):
		is_inside_drop -= 1
		area.modulate = globalVar.transp_red
		area_ref.erase(area)
		print(area_ref)

func _on_timer_timeout() -> void:
	if numProducts > 0:
		numProducts -= 1
		textlabel.text = str(numProducts)
	else:
		#queue_free()
		finish = true

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
	print("saiu")
