@tool
extends EditorPlugin

const LOGGER_SINGLETON = "Logger"

func _enter_tree() -> void:
	add_autoload_singleton(LOGGER_SINGLETON,"logger.gd")

func _exit_tree() -> void:
	remove_autoload_singleton(LOGGER_SINGLETON)
