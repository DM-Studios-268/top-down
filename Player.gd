extends KinematicBody2D

var speed = 300
var dashMultiplier = 3.5
var dashTimeThreshold = 0.2
var dashTimeSpan = 0.2

var velocity = Vector2()
var currentDirection = 0
var states = {}

func _ready():
	pass

func _physics_process(delta):
	velocity = Vector2()
	handleDash(delta, 'up')
	handleDash(delta, 'down')
	handleDash(delta, 'left')
	handleDash(delta, 'right')
	
	handleBasicMovement(delta)
	
	move_and_slide(velocity)
	look_at(get_global_mouse_position())

func handleBasicMovement(delta):
	states['up'] = Input.is_action_pressed("up")
	states['down'] = Input.is_action_pressed("down")
	states['left'] = Input.is_action_pressed("left")
	states['right'] = Input.is_action_pressed("right")
	var fx = 0
	var fy = 0
	var quarterRadian = PI / 2
	
	if states['up'] or states['down'] or (!states['right'] and !states['left']):
		var radians = self.rotation
		currentDirection = radians
	
	if states['up'] or states['down']:
		var x = velocity.x + cos(currentDirection) if states['up'] else velocity.x - cos(currentDirection)
		var y = velocity.y + sin(currentDirection) if states['up'] else velocity.y - sin(currentDirection)
		fx = x * speed
		fy = y * speed
	if states['left'] or states['right']:
		var radians = currentDirection - quarterRadian if states['left'] else currentDirection + quarterRadian
		fx = velocity.x + cos(radians) * speed
		fy = velocity.y + sin(radians) * speed
	velocity = Vector2(fx, fy)

func handleDash(delta, directionString):
	var actionKey = directionString
	var stateKey = directionString + 'DashCounter'
	if Input.is_action_just_pressed(actionKey) and !states.get('dashing'):
		states[stateKey] = states[stateKey] + 1 if states.get(stateKey) else 1
		print(states)
		yield(get_tree().create_timer(dashTimeThreshold),"timeout")
		states[stateKey] = 0
	if Input.is_action_pressed(actionKey) and !states.get('dashing') and states[stateKey] == 2:
		states['dashing'] = true
		speed = speed * dashMultiplier
		yield(get_tree().create_timer(dashTimeSpan),"timeout")
		speed = speed / dashMultiplier
		states['dashing'] = false
