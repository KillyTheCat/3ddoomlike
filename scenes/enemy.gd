extends KinematicBody

var target
var space_state
var gravity = 9.8
var fall = Vector3()
export var speed = 17
export var initialHealth = 100
var health

onready var ray = $RayCast

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		target = body
		print(body.name + "entered")
		set_color_red()


func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		target = null
		print(body.name + "exited")
		set_color_green()
	
func _ready():
	set_color_green()
	space_state = get_world().direct_space_state
	health = initialHealth
	
func _physics_process(delta):
	if target:
		var result = space_state.intersect_ray(global_transform.origin, target.global_transform.origin)
		if result.collider.is_in_group("player"):
			set_color_red()
			look_at(target.global_transform.origin.linear_interpolate(target.transform.origin, 4), Vector3.UP)
			move_to_target(delta)

	else:
		set_color_green()
	if !is_on_floor():
		fall.y -= gravity
	
	move_and_slide(fall, Vector3.UP)
	
	if ray.is_colliding():
		var col = ray.get_collider()
		if(col != null and col.has_method("kill")):
			col.kill()
	
func move_to_target(delta):
	var direction = (target.transform.origin.linear_interpolate(target.transform.origin, 4) - transform.origin).normalized()
	move_and_collide(direction * speed * delta)
	
func get_hurt(hitp):
	health -= hitp
	if health <= 0:
		kill()

func kill():
	queue_free()

func set_color_red():
	$body.get_surface_material(0).set_albedo(Color(1,0,0))
func set_color_green():
	$body.get_surface_material(0).set_albedo(Color(0,1,0))
