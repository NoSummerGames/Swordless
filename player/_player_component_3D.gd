class_name PlayerComponent
extends Node

signal action_entered

var player: Player
var player_stats: PlayerStatsResource:
	get:
		return player.player_stats


func _enter_tree() -> void:
	player = owner
	call_deferred("_setup")


func _setup() ->void:
	pass
