##Simple class that emits a signal when triggered.
##You can connect and use this signal to do whatever in your code.
extends __EventBase
class_name SignalEvent

##The signal emitted when this event is triggered.
signal triggered()

func _trigger():
	triggered.emit()
