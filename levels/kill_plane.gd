extends Area3D


func _on_body_entered(_body: Node3D) -> void:
	get_tree().reload_current_scene.call_deferred()
