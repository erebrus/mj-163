extends MarginContainer


func _ready():
	Events.need_reload.connect(show)
	Events.reloaded.connect(hide)
