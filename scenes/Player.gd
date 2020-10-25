extends KinematicBody


export var MoveSpeed = 4
export var MouseSensetivity = 0.5

export var gravity = 9.8
export var jumpforce = 3

onready var AnimPlayer = $AnimationPlayer
onready var raycast = $Spatial/Camera/RayCast
onready var head = $Spatial
onready var muzzle = $"Spatial/Sci-Fi Gun/Particles"
onready var shotnoise = $"Spatial/Sci-Fi Gun/AudioStreamPlayer3D"

var fall = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= MouseSensetivity * event.relative.x
		head.rotation_degrees.x -= MouseSensetivity * event.relative.y
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))
		
func _physics_process(delta):
	
	var move_vec = Vector3()
	
	if(!is_on_floor()):
		fall.y -= gravity * delta
	
	if(Input.is_action_just_pressed("jump") && is_on_floor()):
		fall.y = jumpforce
		if(fall.y < 0):
			fall.y = fall.y * 1.5
	
	if(Input.is_action_pressed("forward")):
		move_vec.z -= 1
	if(Input.is_action_pressed("backward")):
		move_vec.z += 1
	if(Input.is_action_pressed("moveleft")):
		move_vec.x -= 1
	if(Input.is_action_pressed("moveright")):
		move_vec.x += 1
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0,1,0), rotation.y)
	move_and_collide(MoveSpeed * move_vec * delta)
	move_and_slide(fall, Vector3.UP)
	
	if(Input.is_action_just_pressed("shoot") and !AnimPlayer.is_playing()):
		if(Input.is_action_pressed("look down sight")):
			AnimPlayer.play("shoot down sight")
		else:
			AnimPlayer.play("shoot3d")
		muzzle.restart()
		shotnoise.play()
		if raycast.is_colliding():
			print("stuff in zone")
			var col = raycast.get_collider()
			if(col!=null and col.has_method("get_hurt")):
				col.get_hurt(40)
	
	if(Input.is_action_just_pressed("look down sight")):
		AnimPlayer.play("aim down sight")
	if(Input.is_action_just_released("look down sight")):
		AnimPlayer.play_backwards("aim down sight")
func kill():
	get_tree().reload_current_scene()
	
