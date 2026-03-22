extends CharacterBody2D

@export var tile_size: Vector2 = Vector2(16, 16)
@export var move_speed: float = 100.0

var target_position: Vector2
var moving: bool = false
var collision_shape_node: CollisionShape2D

func _ready():
	target_position = position
	collision_shape_node = $CollisionShape2D

func _physics_process(delta):
	if moving:
		var direction = (target_position - position).normalized()
		var distance = move_speed * delta
		if position.distance_to(target_position) <= distance:
			position = target_position
			moving = false
		else:
			position += direction * distance
	else:
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		)
		input_vector = snap_to_axis(input_vector)

		if input_vector != Vector2.ZERO:
			try_move(input_vector)

# Ensure movement only along one axis
func snap_to_axis(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y):
		return Vector2(sign(v.x), 0)
	elif abs(v.y) > abs(v.x):
		return Vector2(0, sign(v.y))
	return Vector2.ZERO

func try_move(direction: Vector2):
	var new_position = position + direction * tile_size
	if not is_collision(new_position):
		target_position = new_position
		moving = true

func is_collision(new_pos: Vector2) -> bool:
	if collision_shape_node == null or collision_shape_node.shape == null:
		return false

	# Create a query parameters object
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape_node.shape
	query.transform = Transform2D(0, new_pos)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_shape(query)
	return result.size() > 0
