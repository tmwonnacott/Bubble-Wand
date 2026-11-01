extends CharacterBody2D

@export var SPEED = 600.0
const PLAYER_IMMUNITY_TIME = 0.15

var direction := Vector2.ZERO
var immunity_timer := PLAYER_IMMUNITY_TIME
var facing_right := true

@onready var sprite: Sprite2D = $Sprite2D
@onready var wallcollision: CollisionShape2D = $WallCollision
@onready var playercollision: Area2D = $PlayerCollision


func _ready() -> void:
	playercollision.monitoring = true
	playercollision.body_entered.connect(_on_player_collision_body_entered)


func _physics_process(delta: float) -> void:
	# Flip sprite based on direction.
	if direction.x > 0:
		facing_right = true
	elif direction.x < 0:
		facing_right = false

	sprite.scale.x = 1 if facing_right else -1

	# Immunity timer and temporary speed boost for player bubbles.
	var current_speed = SPEED
	if is_in_group('player_bubble'):
		if immunity_timer > 0:
			current_speed += 200
			immunity_timer -= delta
	else:
		immunity_timer = 0

	velocity = direction * current_speed

	# Wall collision only.
	var collision = move_and_collide(velocity * delta)

	if collision:
		var normal = collision.get_normal()
		direction = direction.bounce(normal)


# Player collision only.
func _on_player_collision_body_entered(body: Node2D) -> void:
	# Ignore player collisions during initial immunity.
	if immunity_timer > 0 and is_in_group("player_bubble"):
		return

	if not body.is_in_group("player"):
		return

	var difference = body.global_position - global_position

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
