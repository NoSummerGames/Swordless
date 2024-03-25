class_name PlayerComponent
extends Node

var player: Player
var player_stats: PlayerStatsResource


func _enter_tree() -> void:
	player = owner
	player_stats = player.player_stats
	call_deferred("_setup")


func _setup() ->void:
	pass

