extends Area2D

@onready var capture_point: Marker2D = $CapturePoint

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("bubble"):
		return

	body.add_to_group("caught_bubble")

	# Stop the bubble from moving or bouncing away.
	body.set_physics_process(false)
	body.velocity = Vector2.ZERO

	# Move it into the catcher.
	body.reparent(self)
	body.global_position = capture_point.global_position
