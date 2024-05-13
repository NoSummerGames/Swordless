extends Node

enum Inputs {
	SELECTED = 0,
	UNSELECTED = 1,
	PRESSED = 2,
	RELEASED = 3
}


enum Actions {
	NONE = 0,
	JUMP = 1,
	SPRINT = 2,
	DASH = 3,
	SLIDE = 4,
	STRAFE = 5,
	FREEZE = 6

}

enum ActionParams {
	NONE = 0,
	LEFT = 1,
	RIGHT = 2,
	START = 3,
	END = 4
}

enum PartDifficulties {
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
	EVIL = 3
}
