extends Sprite2D

const MIN_BARK_INTERVAL=5000
var last_run_time=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate=Color("#ffffff00")
	
func show_text(text:String)->void:

	if Time.get_ticks_msec()- last_run_time < MIN_BARK_INTERVAL:
		Logger.debug("Ignoring bark. Too soon. %d ms" % [Time.get_ticks_msec()- last_run_time])
		return
	$Label.text=text
	modulate=Color("#ffffff00")
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color("#ffffffff"),1)
	await tween.finished
	$Timer.start()
	
func _on_timer_timeout() -> void:
	last_run_time=Time.get_ticks_msec()
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color("#ffffff00"),.5)
	await tween.finished
	
