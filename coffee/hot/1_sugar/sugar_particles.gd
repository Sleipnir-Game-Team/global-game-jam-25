extends CPUParticles2D


func _on_finished() -> void:
	get_parent().queue_free()
