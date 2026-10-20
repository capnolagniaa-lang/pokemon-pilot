extends RefCounted
## Generado por tools/download_sprites.ps1 - no editar a mano.

const ANIMS := {
	1: {
		"portrait": "res://sprites/pokemon/0001/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0001/Idle-Anim.png", "w": 32, "h": 40, "durations": [40, 6, 6]},
		"Walk": {"file": "res://sprites/pokemon/0001/Walk-Anim.png", "w": 40, "h": 40, "durations": [4, 4, 4, 4, 4, 4]},
		"Attack": {"file": "res://sprites/pokemon/0001/Attack-Anim.png", "w": 64, "h": 72, "durations": [4, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4]},
		"Hurt": {"file": "res://sprites/pokemon/0001/Hurt-Anim.png", "w": 40, "h": 56, "durations": [2, 8]},
	},
	4: {
		"portrait": "res://sprites/pokemon/0004/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0004/Idle-Anim.png", "w": 32, "h": 40, "durations": [12, 8, 8, 8]},
		"Walk": {"file": "res://sprites/pokemon/0004/Walk-Anim.png", "w": 32, "h": 32, "durations": [6, 8, 6, 8]},
		"Attack": {"file": "res://sprites/pokemon/0004/Attack-Anim.png", "w": 64, "h": 64, "durations": [2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0004/Hurt-Anim.png", "w": 48, "h": 56, "durations": [2, 8]},
	},
	7: {
		"portrait": "res://sprites/pokemon/0007/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0007/Idle-Anim.png", "w": 32, "h": 32, "durations": [30, 2, 2, 4, 4, 4, 2, 2]},
		"Walk": {"file": "res://sprites/pokemon/0007/Walk-Anim.png", "w": 32, "h": 32, "durations": [12, 8, 12, 8]},
		"Attack": {"file": "res://sprites/pokemon/0007/Attack-Anim.png", "w": 64, "h": 72, "durations": [2, 4, 1, 1, 1, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0007/Hurt-Anim.png", "w": 40, "h": 56, "durations": [2, 8]},
	},
	16: {
		"portrait": "res://sprites/pokemon/0016/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0016/Idle-Anim.png", "w": 24, "h": 40, "durations": [30, 4, 4, 4, 4]},
		"Walk": {"file": "res://sprites/pokemon/0016/Walk-Anim.png", "w": 32, "h": 32, "durations": [6, 4, 4, 4, 4]},
		"Attack": {"file": "res://sprites/pokemon/0016/Attack-Anim.png", "w": 64, "h": 72, "durations": [2, 2, 2, 4, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0016/Hurt-Anim.png", "w": 48, "h": 48, "durations": [2, 8]},
	},
	19: {
		"portrait": "res://sprites/pokemon/0019/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0019/Idle-Anim.png", "w": 32, "h": 32, "durations": [40, 2, 2, 2, 4, 2, 2, 2]},
		"Walk": {"file": "res://sprites/pokemon/0019/Walk-Anim.png", "w": 48, "h": 40, "durations": [6, 4, 4, 4, 4, 4, 4]},
		"Attack": {"file": "res://sprites/pokemon/0019/Attack-Anim.png", "w": 64, "h": 72, "durations": [2, 4, 1, 1, 1, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0019/Hurt-Anim.png", "w": 56, "h": 56, "durations": [2, 8]},
	},
	37: {
		"portrait": "res://sprites/pokemon/0037/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0037/Idle-Anim.png", "w": 32, "h": 32, "durations": [40, 12, 20, 12]},
		"Walk": {"file": "res://sprites/pokemon/0037/Walk-Anim.png", "w": 32, "h": 40, "durations": [6, 4, 4, 4, 6]},
		"Attack": {"file": "res://sprites/pokemon/0037/Attack-Anim.png", "w": 72, "h": 72, "durations": [4, 2, 6, 1, 1, 2, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0037/Hurt-Anim.png", "w": 40, "h": 56, "durations": [2, 8]},
	},
	43: {
		"portrait": "res://sprites/pokemon/0043/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0043/Idle-Anim.png", "w": 24, "h": 40, "durations": [30, 4, 4, 4, 4]},
		"Walk": {"file": "res://sprites/pokemon/0043/Walk-Anim.png", "w": 24, "h": 40, "durations": [8, 4, 8, 6, 8, 4, 8, 6]},
		"Attack": {"file": "res://sprites/pokemon/0043/Attack-Anim.png", "w": 72, "h": 80, "durations": [2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0043/Hurt-Anim.png", "w": 56, "h": 48, "durations": [2, 8]},
	},
	54: {
		"portrait": "res://sprites/pokemon/0054/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0054/Idle-Anim.png", "w": 24, "h": 40, "durations": [16, 20, 16, 20]},
		"Walk": {"file": "res://sprites/pokemon/0054/Walk-Anim.png", "w": 24, "h": 40, "durations": [8, 12, 8, 12]},
		"Attack": {"file": "res://sprites/pokemon/0054/Attack-Anim.png", "w": 72, "h": 72, "durations": [4, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4]},
		"Hurt": {"file": "res://sprites/pokemon/0054/Hurt-Anim.png", "w": 40, "h": 56, "durations": [2, 8]},
	},
	58: {
		"portrait": "res://sprites/pokemon/0058/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0058/Idle-Anim.png", "w": 40, "h": 48, "durations": [40, 4, 2]},
		"Walk": {"file": "res://sprites/pokemon/0058/Walk-Anim.png", "w": 32, "h": 40, "durations": [6, 8, 6, 8]},
		"Attack": {"file": "res://sprites/pokemon/0058/Attack-Anim.png", "w": 72, "h": 80, "durations": [2, 2, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0058/Hurt-Anim.png", "w": 48, "h": 48, "durations": [2, 8]},
	},
	60: {
		"portrait": "res://sprites/pokemon/0060/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0060/Idle-Anim.png", "w": 40, "h": 48, "durations": [30, 8, 6, 6, 4, 4, 4, 4]},
		"Walk": {"file": "res://sprites/pokemon/0060/Walk-Anim.png", "w": 32, "h": 40, "durations": [8, 6, 6, 6, 6]},
		"Attack": {"file": "res://sprites/pokemon/0060/Attack-Anim.png", "w": 72, "h": 72, "durations": [2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0060/Hurt-Anim.png", "w": 48, "h": 40, "durations": [2, 8]},
	},
	69: {
		"portrait": "res://sprites/pokemon/0069/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0069/Idle-Anim.png", "w": 24, "h": 32, "durations": [20, 22]},
		"Walk": {"file": "res://sprites/pokemon/0069/Walk-Anim.png", "w": 24, "h": 32, "durations": [8, 10, 8, 10]},
		"Attack": {"file": "res://sprites/pokemon/0069/Attack-Anim.png", "w": 72, "h": 72, "durations": [2, 4, 1, 1, 1, 2, 2, 2, 2, 2]},
		"Hurt": {"file": "res://sprites/pokemon/0069/Hurt-Anim.png", "w": 48, "h": 48, "durations": [2, 8]},
	},
	133: {
		"portrait": "res://sprites/pokemon/0133/portrait.png",
		"Idle": {"file": "res://sprites/pokemon/0133/Idle-Anim.png", "w": 24, "h": 32, "durations": [16, 16]},
		"Walk": {"file": "res://sprites/pokemon/0133/Walk-Anim.png", "w": 40, "h": 48, "durations": [4, 4, 4, 4, 6, 2, 2]},
		"Attack": {"file": "res://sprites/pokemon/0133/Attack-Anim.png", "w": 64, "h": 72, "durations": [4, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4]},
		"Hurt": {"file": "res://sprites/pokemon/0133/Hurt-Anim.png", "w": 48, "h": 48, "durations": [2, 8]},
	},
}
