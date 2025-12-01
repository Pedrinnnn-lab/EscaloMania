class_name drop_area
extends Area2D

@export var next_drop : Area2D

#variavel usada para verificar quantos clientes estão em cima do drop
@export var lista_drop : Array[Area2D]
var lista_click : Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = globalVar.transp_red

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if globalVar.is_dragging: visible = true
	else: visible = false
	
func on_area_entered(client: Area2D) -> void:
	if client.is_in_group("client"):
			lista_drop.append(client)
			print("Slot de fila ocupado por: ", client.get_parent().name)
			if not lista_drop.is_empty():
				print("o cliente foi adicionado na lista")
		
func on_area_exited(client: Area2D) -> void:
	if client.is_in_group("client"):
		lista_drop.erase(client)
		print("Slot de fila liberado por: ", client.get_parent().name)
	
