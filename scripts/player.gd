extends CharacterBody2D

enum PlayerState {
	idle,
	run,
	jump,
	fall
}
# busca a referencia
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const SPEED = 80.0
const JUMP_VELOCITY = -350.0

var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.run:
			run_state()
		PlayerState.jump:
			jump_state()
		PlayerState.fall:
			fall_state()
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")
	reset_collision_shape()

func go_to_walk_state():
	status = PlayerState.run
	anim.play("run")
	reset_collision_shape()

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	reset_collision_shape()

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")
	# ajusta o shape durante a queda
	collision_shape_2d.shape.radius = 12
	collision_shape_2d.shape.height = 40
	collision_shape_2d.position.y = 0

func idle_state():
	move()
	if  velocity.x != 0:
		go_to_walk_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if not is_on_floor() and velocity.y > 0: # caiu sem pular
		go_to_fall_state()
		return
	

func run_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if not is_on_floor() and velocity.y > 0: # caiu correndo
		go_to_fall_state()
		return

func jump_state():
	move()
	# Se começou a descer, troca para fall
	if velocity.y > 0:
		go_to_fall_state()
		return

	# se tocou no chão direto (pulo muito curto)
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func fall_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func move():
	
	update_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	

func update_direction():
	
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func reset_collision_shape():
	# valores padrões (ajusta conforme o seu sprite)
	collision_shape_2d.shape.radius = 7
	collision_shape_2d.shape.height = 42
	collision_shape_2d.position.y = 0
