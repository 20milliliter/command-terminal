class_name FocusAwareControl 
extends Control

func _input(event):
	if not self.has_focus(): return
	if not event is InputEventMouseButton: return
	if not event.pressed: return
	var control_rect = self.get_rect()
	control_rect.position = Vector2.ZERO
	var local_rect = control_rect
	if local_rect.has_point(get_local_mouse_position()): return
	self.release_focus()
	clicked_out_of.emit()

signal clicked_out_of()