extends RefCounted
class_name PolySignal

## Class that allows waiting for one or more signals.
##
## You can wait for two or more signals to be completed,
## or for any of them to be completed;

## The signal that's emitted 
signal emitted

var _wait_for_both : bool = true
var _left
var _right

var left_completed : bool = false
var right_completed : bool = false

## Creates a PolySignal that waits for at least one of the signals.
static func any(left, right) -> PolySignal:
	return _create(left, right, false)

## Creates a PolySignal that waits for both signals.
static func both(left, right) -> PolySignal:
	return _create(left, right, true)

static func _create(left, right, wait_for_both) -> PolySignal:
	var psignal := PolySignal.new()
	psignal._wait_for_both = wait_for_both
	if left is PolySignal:
		left = left.emitted
	if right is PolySignal:
		right = right.emitted
	
	left.connect(
		func set_left_completed():
			psignal.left_completed = true
			psignal._test_completion()
	)
	
	right.connect(
		func set_right_completed():
			psignal.right_completed = true
			psignal._test_completion()
	)
	return psignal

func _test_completion():
	if _wait_for_both:
		if left_completed and right_completed:
			emitted.emit()
			free()
	else:
		if left_completed or right_completed:
			emitted.emit()
			free()
