extends Node2D


@onready var pieces_folder = $Pieces
@onready var tile_map = $TileMapLayer
@onready var camera = $Camera2D
var selected_piece = null
var is_selected = false
var valid_moves = []
func _ready():
	$CanvasLayer/Button.pressed.connect(_on_button_pressed)
	for piece in pieces_folder.get_children():
		var start_cell = tile_map.local_to_map(piece.position)
		piece.position = tile_map.map_to_local(start_cell)
	camera.position = $Pieces/Rook.position
func select_piece(piece: Piece, cell: Vector2i):
	selected_piece = piece
	camera.position = selected_piece.position
	valid_moves = selected_piece.get_piece_moves(cell, tile_map, pieces_folder.get_children())
	queue_redraw()
func move_selected_piece(target_cell: Vector2i):
	valid_moves = selected_piece.get_piece_moves(target_cell, tile_map, pieces_folder.get_children())
	var target_pos = tile_map.map_to_local(target_cell)
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(selected_piece, "position", target_pos, 0.2)
	camera.position = target_pos
	queue_redraw()
	
	await tween.finished
	print("Checking checkmate: ", black_king_checkmated())
	if selected_piece != null and selected_piece.type == Piece.PieceType.PAWN:
		if tile_map.get_cell_source_id(target_cell + Vector2i.UP) == -1:
				selected_piece.promote_to_queen()
	if black_king_checkmated():
		$CanvasLayer/Label.visible = true
		deselect_piece()
	elif selected_piece != null:
		valid_moves = selected_piece.get_piece_moves(target_cell, tile_map, pieces_folder.get_children())
		queue_redraw()
func get_piece_at_cell(cell: Vector2i) -> Piece:
	for piece in pieces_folder.get_children():
		var piece_cell = tile_map.local_to_map(piece.position)
		if cell == piece_cell:
			return piece
	return null
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pixels = tile_map.get_local_mouse_position()
		var clicked_cell = tile_map.local_to_map(mouse_pixels)
		var clicked_piece = get_piece_at_cell(clicked_cell)
		
		if clicked_piece != null and clicked_piece.team == Piece.Team.WHITE:
			if clicked_piece == selected_piece:
				deselect_piece()
			else:
				select_piece(clicked_piece, clicked_cell)
		elif selected_piece!=null and clicked_cell in valid_moves and clicked_piece ==null:
			move_selected_piece(clicked_cell)
		else:
			deselect_piece()
func _draw():
	if selected_piece != null:
		for cell in valid_moves:
			var center = tile_map.map_to_local(cell)
			var top_left = center - Vector2(22, 22)
			draw_rect(Rect2(top_left, Vector2(44, 44)), Color(1.0, 0.8, 0.2, 0.451))
func deselect_piece():
	selected_piece = null
	valid_moves.clear()
	queue_redraw()
func is_square_attacked_by_white(cell: Vector2i) -> bool:
	for piece in pieces_folder.get_children():
		if piece.team == Piece.Team.WHITE:
			var piece_cell = tile_map.local_to_map(piece.position)
			var attacks = piece.get_piece_moves(piece_cell, tile_map, pieces_folder.get_children())
			if cell in attacks:
				return true
	return false

func black_king_checkmated() -> bool:
	var king_cell = tile_map.local_to_map($"Pieces/Black King".position)
	
	if not is_square_attacked_by_white(king_cell):
		return false
		
	var neighbors = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
		Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)
	]
	
	for dir in neighbors:
		var neighbor_cell = king_cell + dir
		if tile_map.get_cell_source_id(neighbor_cell) == -1:
			continue
		if get_piece_at_cell(neighbor_cell) != null:
			continue
		if not is_square_attacked_by_white(neighbor_cell):
			return false
			
	return true
func _on_button_pressed():
	get_tree().reload_current_scene()
