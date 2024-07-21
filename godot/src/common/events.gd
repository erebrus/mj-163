extends Node

signal child_exited_arena(child:Child)
signal child_entered_arena(child:Child)
signal on_feed(child:Child)
signal on_bad_feed(child:Child)
signal tick()

signal need_reload
signal reloaded

signal score_changed(score:int, flash:bool)
signal happiness_changed(value)
signal dessert_spawn_requested(stand)
