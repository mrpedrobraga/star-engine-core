@tool
extends Container
class_name RemoteContainer

var _target : RemoteContainer
var _tween : Tween

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		for child in get_children():
			print('sort children')
			if size < (child as Control).get_minimum_size():
				custom_minimum_size = (child.get_minimum_size())
			fit_child_in_rect(
				child,
				Rect2(
					Vector2(),
					size
				)
			)

func move(target : RemoteContainer, duration : float) -> void:
	_tween = create_tween()
	for child in get_children():
		_tween.tween_method(
			(
				func(t : float):
					var self_rect := Rect2(self.global_position, self.size)
					var target_rect := Rect2(target.global_position, target.size)
					fit_child_in_rect(
						child,
						Rect2(
							lerp(self_rect.position, target_rect.position, t),
							lerp(self_rect.size    , target_rect.size    , t)
						)
					)),
			0.0, 1.0, duration
		)
