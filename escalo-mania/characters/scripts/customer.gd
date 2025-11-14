extends CharacterBody2D

var numProducts : int
@onready var textlabel = $text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	numProducts = randi_range(1,15)
	textlabel.text = str(numProducts)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
