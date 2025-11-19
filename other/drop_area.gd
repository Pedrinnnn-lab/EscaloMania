extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = globalVar.transp_red

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if globalVar.is_dragging: visible = true
	else: visible = false
