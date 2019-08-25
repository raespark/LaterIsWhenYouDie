extends ScrollContainer

var following: bool = false;
onready var bar:VScrollBar = get_v_scrollbar()

func scroll_to_bottom():
	bar.value = bar.max_value;
	update()

func _on_MarginContainer_resized():
	following = bar.value + bar.page >= bar.max_value;
	yield(get_tree(), "idle_frame")
	if (following):
		scroll_to_bottom()