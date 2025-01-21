extends Node2D
## Component to add Drag n' Drop functionality to a parent Area2D.
## Supports dynamically transferring the component.

## Whether or not the parent Area2D is currently being dragged.
var _dragging: bool = false

## Distance of mouse click from parent's origin.
## Used to avoid "jumps" when starting a drag from the parent's edge.
var _drag_offset: Vector2 = Vector2.ZERO

## The target Area2D node.
## Setter function includes logic to disconnect the previous parent and connect the new one.
var _parent_node: Area2D:
	set(new_parent):
		# Checking if previous connections exist and removing then
		# This only happens if this "Draggable" component for some reason gets transferred to a different parent
		if _parent_node and _parent_node.input_event.is_connected(drag_input_handler):
			_parent_node.input_event.disconnect(drag_input_handler)
		
		_parent_node = new_parent
		_parent_node.input_event.connect(drag_input_handler)

## Event Handler for [signal CollisionObject2D.input_event].
## Responsible for starting the drag event using the parent's area collision
func drag_input_handler(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		_drag_offset = _parent_node.get_local_mouse_position()
		_dragging = true

## Event Handler for dragging and dropping the parent.
## This isn't included drag_input_handler because [signal CollisionObject2D.input_event]
## only emits when the mouse is hovering the Area2D, and when moving the mouse fast enough
## the Area2D might lag behind the mouse's actual position
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_parent_node.global_position = get_global_mouse_position() - _drag_offset


## Event Handler for NOTIFICATION_PARENTED (when this component gets a new parent)
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			_parent_node = get_parent()
