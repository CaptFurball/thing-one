extends Area

export var rotate_vector: Vector3
export var rotate_speed: Vector3 = Vector3(0.5, 0.5, 0.5)

onready var map = get_node("../")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_RotateTrigger_body_entered(_body):
	if map.has_method("rotate_map"):
		map.rotate_map(rotate_vector, rotate_speed)
