extends Menu
class_name IconMenu

## [Menu], but also has icons.
##
## Check [Menu] for a good documentation.

@export var icons : Array[Texture2D] = []

static func create(
	_options : Array,
	_labels : Array = [],
	_icons : Array = [],
	_allows_cancel = false,
	_menu_handler : Node = null
) -> Menu:
	var m = IconMenu.new()
	
	m.options = _options
	m.labels.assign(_labels)
	m.allows_cancel = _allows_cancel
	m.icons = _icons
	if _menu_handler:
		m.menu_handler = _menu_handler
		_menu_handler.menu = m
	return m

func open(parent_=null, level_=0):
	menu_handler.icons = icons
	super(parent_, level_)
