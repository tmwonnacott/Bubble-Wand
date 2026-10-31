
extends CharacterBody2D

@export var SPEED = 600.0
const PLAYER_IMMUNITY_TIME = 0.15

var direction := Vector2.ZERO
var immunity_timer := PLAYER_IMMUNITY_TIME
var player: CharacterBody2D
var facing_right := true
var hitbox_offset: float

@onready var sprite: Sprite2D = $Sprite2D
@onready var wallcollision: CollisionShape2D = $WallCollision
@onready var playercollision: Area2D = $PlayerCollision


func _ready() -> void:
	add_to_group("bubble")

	player = get_tree().get_first_node_in_group("player")

	hitbox_offset = abs(playercollision.position.x)

	# Disable player detection during initial immunity.
	playercollision.monitoring = false

	# Connect player detection.
	playercollision.body_entered.connect(_on_player_collision_body_entered)


func _physics_process(delta: float) -> void:

	# Flip sprite and player hitbox based on direction.
	if direction.x > 0:
		facing_right = true
	elif direction.x < 0:
		facing_right = false

	sprite.scale.x = 1 if facing_right else -1

	playercollision.position.x = (
		hitbox_offset if facing_right else -hitbox_offset
	)

	# Immunity timer and temporary speed boost.
	var current_speed = SPEED

	if immunity_timer > 0:
		current_speed += 200
		immunity_timer -= delta

		if immunity_timer <= 0:
			playercollision.monitoring = true

	velocity = direction * current_speed

	# WALL COLLISION ONLY.
	var collision = move_and_collide(velocity * delta)

	if collision:
		var normal = collision.get_normal()

		print("Wall collision normal: ", normal)

		direction = direction.bounce(normal)


# PLAYER COLLISION ONLY.
func _on_player_collision_body_entered(body: Node2D) -> void:

	if not body.is_in_group("player"):
		return

	var difference = body.global_position - global_position

	print("Player hit direction: ", difference)

	# Determine whether the player hit horizontally or vertically.
	if difference.y < -30:
		body.bounce_on_bubble()

	elif abs(difference.x) > abs(difference.y):

		# Horizontal hit.
		if difference.x > 0:
			body.velocity.x = 400
		else:
			body.velocity.x = -400

	else:

		# Vertical hit from below.
		body.velocity.y = 400

	queue_free()
