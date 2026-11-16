extends Node2D

class_name Piece

enum PieceType { ROOK, BISHOP, KNIGHT, QUEEN, KING, PAWN }
enum Team { WHITE, BLACK }

@export var type: PieceType = PieceType.ROOK
@export var team: Team = Team.WHITE
@export var texture: Texture2D
@export var target_pixel_size: float = 36.0

var grid_cell: Vector2i


func _ready():
	if texture:
		$Sprite2D.texture = texture
		var img_size = texture.get_size()
		var scale_factor = target_pixel_size / max(img_size.x, img_size.y)
		$Sprite2D.scale = Vector2(scale_factor, scale_factor)

func get_piece_at(cell: Vector2i, all_pieces: Array, tile_map: TileMapLayer) -> Piece:
	for p in all_pieces:
		if tile_map.local_to_map(p.position) == cell:
			return p
	return null

func get_piece_moves(start_cell: Vector2i, tile_map: TileMapLayer, all_pieces: Array) -> Array[Vector2i]:
	if type == PieceType.ROOK:
		return get_rook_moves(start_cell, tile_map, all_pieces)
	elif type == PieceType.BISHOP:
		return get_bishop_moves(start_cell, tile_map, all_pieces)
	elif type == PieceType.KNIGHT:
		return get_knight_moves(start_cell, tile_map, all_pieces)
	elif type == PieceType.PAWN:
		return get_pawn_moves(start_cell, tile_map, all_pieces)
	else:
		return get_queen_moves(start_cell, tile_map, all_pieces)

func get_rook_moves(start_cell: Vector2i, tile_map: TileMapLayer, all_pieces: Array) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for direction in directions:
		var current_cell = start_cell + direction
		while tile_map.get_cell_source_id(current_cell) != -1:
			var occupant = get_piece_at(current_cell, all_pieces, tile_map)
			if occupant != null:
				if occupant.team == Team.BLACK:
					moves.append(current_cell)
				break
			moves.append(current_cell)
			current_cell += direction
	return moves

func get_bishop_moves(start_cell: Vector2i, tile_map: TileMapLayer, all_pieces: Array) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	var directions = [
		Vector2i(-1, -1), Vector2i(1, -1),
		Vector2i(-1, 1), Vector2i(1, 1)
	]
	for direction in directions:
		var current_cell = start_cell + direction
		while tile_map.get_cell_source_id(current_cell) != -1:
			var occupant = get_piece_at(current_cell, all_pieces, tile_map)
			if occupant != null:
				if occupant.team == Team.BLACK:
					moves.append(current_cell)
				break
			moves.append(current_cell)
			current_cell += direction
	return moves

func get_knight_moves(start_cell: Vector2i, tile_map: TileMapLayer, all_pieces: Array) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	var jumps = [
		Vector2i(-1, -2), Vector2i(1, -2),
		Vector2i(-1, 2), Vector2i(1, 2),
		Vector2i(-2, -1), Vector2i(-2, 1),
		Vector2i(2, -1), Vector2i(2, 1)
	]
	for jump in jumps:
		var target_cell = start_cell + jump
		if tile_map.get_cell_source_id(target_cell) != -1:
			var occupant = get_piece_at(target_cell, all_pieces, tile_map)
			if occupant == null or occupant.team == Team.BLACK:
				moves.append(target_cell)
	return moves
func get_pawn_moves(start_cell: Vector2i, tile_map: TileMapLayer, all_pieces: Array) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	
	var forward_cell = start_cell + Vector2i.UP
	if tile_map.get_cell_source_id(forward_cell) != -1:
		if get_piece_at(forward_cell, all_pieces, tile_map) == null:
			moves.append(forward_cell)
			
	return moves
func get_queen_moves(start_cell: Vector2i, tile_map: TileMapLayer, all_pieces: Array) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	moves.append_array(get_rook_moves(start_cell, tile_map, all_pieces))
	moves.append_array(get_bishop_moves(start_cell, tile_map, all_pieces))
	return moves

func promote_to_queen():
	type = PieceType.QUEEN
	var queen_tex = load("res://Queen.png")
	if queen_tex != null:
		$Sprite2D.texture = queen_tex
		var img_size = queen_tex.get_size()
		var scale_factor = target_pixel_size / max(img_size.x, img_size.y)
		$Sprite2D.scale = Vector2(scale_factor, scale_factor)
