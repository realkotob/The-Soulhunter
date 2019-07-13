class_name Controls
extends Node

enum{ATTACK, JUMP, UP, RIGHT, DOWN, LEFT, SOUL, ACCEPT, CANCEL, MAP, MENU, CHAT, COMMAND}

enum State{NONE, ACTION, CHAT, MENU, MAP, GAME_OVER}
var state = State.NONE

signal key_press(p_id, key, state)
signal key_release(p_id, key, state)

var players = {}
var controls = {}

func _ready():
	set_process(false)

func _process(delta):
	match state:
		State.ACTION:
			process_key_local(MENU, KEY_BACKSLASH)
			process_key_local(MAP, KEY_TAB)
			process_key_local(CHAT, KEY_T)
			process_key_local(COMMAND, KEY_SLASH)
			
			process_key(UP, KEY_UP)
			process_key(RIGHT, KEY_RIGHT)
			process_key(LEFT, KEY_LEFT)
			process_key(JUMP, KEY_SPACE)
			process_key(ATTACK, KEY_CONTROL)
			process_key(SOUL, KEY_SHIFT)
		
		State.CHAT:
			process_key_local(ACCEPT, KEY_ENTER)
			process_key_local(CANCEL, KEY_BACKSPACE)
		
		State.MENU:
			process_key_local(MENU, KEY_BACKSLASH)
			process_key_local(ACCEPT, KEY_ENTER)
			process_key_local(CANCEL, KEY_BACKSPACE)
			process_key_local(SOUL, KEY_SHIFT)
			
			process_key_local(CHAT, KEY_T)
			process_key_local(COMMAND, KEY_SLASH)
			
			process_key_local(UP, KEY_UP)
			process_key_local(DOWN, KEY_DOWN)
			process_key_local(RIGHT, KEY_RIGHT)
			process_key_local(LEFT, KEY_LEFT)
		
		State.MAP:
			process_key_local(UP, KEY_UP)
			process_key_local(DOWN, KEY_DOWN)
			process_key_local(RIGHT, KEY_RIGHT)
			process_key_local(LEFT, KEY_LEFT)
			process_key_local(MAP, KEY_TAB)
		
		State.GAME_OVER:
			process_key_local(ACCEPT, KEY_ENTER)
			process_key_local(CANCEL, KEY_BACKSPACE)

func process_key(key_id, key):
	if Input.is_key_pressed(key) and !controls.has(key_id):
		Packet.new(Packet.TYPE.KEY_PRESS).add_u8(key_id).send()
		process_key_local(key_id, key)
	elif !Input.is_key_pressed(key) and controls.has(key_id):
		Packet.new(Packet.TYPE.KEY_RELEASE).add_u8(key_id).send()
		process_key_local(key_id, key)

func process_key_local(key_id, key):
	if Input.is_key_pressed(key) and !controls.has(key_id):
		controls[key_id] = true
		Com.press_key(key_id)
		if Com.player and is_instance_valid(Com.player):
			press_key(Com.player.get_meta("id"), key_id)
		else:
			press_key(-1, key_id)
	elif !Input.is_key_pressed(key) and controls.has(key_id):
		controls.erase(key_id)
		Com.release_key(key_id)
		if Com.player and is_instance_valid(Com.player):
			release_key(Com.player.get_meta("id"), key_id)
		else:
			release_key(-1, key_id)

func press_key(player_id, key, state_override = state):
	emit_signal("key_press", player_id, key, state_override)

func release_key(player_id, key, state_override = state):
	emit_signal("key_release", player_id, key, state_override)