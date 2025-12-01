extends Node2D

var velocity = 200
var alvo_slot: drop_area = null
var numProducts : int
var draggable : bool = false
var is_inside_drop : int = 0
var area_ref : Array[Area2D]
var drag_offset : Vector2
var init_pos : Vector2
var scale_init : Vector2
var finish : bool = false
var buying : bool = false
var walk : bool = false
var go_ahead: bool = false
var fila : bool = false
var drop_atual: Area2D = null
@onready var textlabel = $text
@onready var timer = $Timer
@onready var stress_bar = $StressBar # Para a barra de estresse

var tempo_limite_fora = 20.0
var tempo_limite_dentro = 30.0
var tempo_atual_estresse = 0.0
var estressado = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	numProducts = randi_range(1,15)
	textlabel.text = str(numProducts)
	scale_init = scale
	reset_stress_bar(tempo_limite_fora)

func _process(delta: float) -> void:
	
	if finish:
		position.x -= 5
		stress_bar.visible = true # Barra vai aparecer
	#print(area_ref)
	
	if estressado:
		tempo_atual_estresse -= delta
		stress_bar.value = tempo_atual_estresse
		
		if tempo_atual_estresse < 5.0: # A barra vai ficar vermelha
			stress_bar.modulate = Color(1,0,0)
		elif tempo_atual_estresse < 14.0:
			stress_bar.modulate = Color(1,0.8,0)
		else: # A Barra continua verde
			stress_bar.modulate = Color(0,1,0)
		# Se acabar, chama a funçao de game over
		if tempo_atual_estresse <= 0: 
			game_over_patience()
			
	if draggable and not buying:
		if Input.is_action_just_pressed("click"):
			init_pos = global_position
			drag_offset = get_global_mouse_position() - global_position
			globalVar.is_dragging = true
			if is_instance_valid(alvo_slot):
				alvo_slot.lista_click.erase(self)
				dropping_logic()
				fila = false
				buying = false
				alvo_slot = null
		
		if Input.is_action_pressed("click"):
			position = get_global_mouse_position() - drag_offset
			
		elif Input.is_action_just_released("click"):
			globalVar.is_dragging = false 
			dropping_logic()
			
	
	if fila and is_instance_valid(alvo_slot):
		var next_slot : drop_area = alvo_slot.next_drop
		go_ahead = true
		moving_ahead(delta)
		if global_position.distance_to(alvo_slot.global_position + Vector2(0,-75)) < 10:
			if next_slot == null:
				fila = false
				timer.start()
				buying = true
				
			elif next_slot != null and not next_slot.lista_drop.is_empty():
				pass
			else:
					var slot_anterior = alvo_slot
					alvo_slot = next_slot
					if slot_anterior != null:
						slot_anterior.lista_drop.erase(self)
						
					if alvo_slot == null:
						fila = false
						timer.start()
						buying = true
	
func reset_stress_bar(amount: float) -> void:
	tempo_atual_estresse = amount
	stress_bar.max_value = amount
	stress_bar.value = amount
	stress_bar.modulate = Color(1, 1, 1) # Reseta a cor

# O que acontece quando o estresse acaba
func game_over_patience() -> void:
	print("O cliente ficou irritado e foi embora!")
	estressado = false
	finish = true # Faz ele ir embora
	# Talvez add um som o algo do tipo...
	
func _on_area_2d_mouse_entered() -> void:
	if not globalVar.is_dragging:
		draggable = true
		scale = scale_init * 1.1

func _on_area_2d_mouse_exited() -> void:
	if not globalVar.is_dragging:
		draggable = false
		scale = scale_init

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("drop"):
		is_inside_drop += 1
		area.modulate = globalVar.transp_green
		area_ref.push_front(area)
		print(area_ref)
		drop_atual = area_ref[0]
		print("Drop Atual: ", drop_atual.name)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("drop"):
		is_inside_drop -= 1
		area.modulate = globalVar.transp_red
		area_ref.erase(area)
		print(area_ref)
		if drop_atual == area:
			if not area_ref.is_empty():
				drop_atual = area_ref[0]
			else:
				drop_atual = null
		
		print("Drop Atual: ", drop_atual.name if drop_atual else "Nenhum")

func _on_timer_timeout() -> void:
	if buying:
		if numProducts > 0:
			numProducts -= 1
			textlabel.text = str(numProducts)
			tempo_atual_estresse += 2.0
			stress_bar.value = tempo_atual_estresse
		else:
			if is_instance_valid(alvo_slot):
				alvo_slot.lista_click.erase(self)
				dropping_logic()
			
			alvo_slot = null # Limpa a referência do drop
			finish = true
		
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	if finish:
		estressado = false
		queue_free()
		print("free")
	else:
		position = init_pos
		scale = scale_init
		
func moving_ahead(delta: float) -> void:
	if alvo_slot != null:
		var target_position = alvo_slot.global_position + Vector2(0,-75)
		global_position = global_position.move_toward(target_position, velocity * delta)
		
func dropping_logic() -> void:
	var tween = get_tree().create_tween()
	if is_inside_drop > 0 and not area_ref.is_empty():
		var drop_solto = area_ref[0]
		if drop_solto.lista_drop.size() <= 1:
			if drop_solto.is_in_group("first"):
				timer.start()
				buying = true
				fila = false
			else:
				alvo_slot = drop_solto
				fila = true
			tween.tween_property(self,"global_position", drop_solto.global_position + Vector2(0,-75),0.2).set_ease(Tween.EASE_OUT)
		else:
			tween.tween_property(self,"global_position",init_pos,0.2).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self,"global_position",init_pos,0.2).set_ease(Tween.EASE_OUT)
	
	
		

	
	
	
