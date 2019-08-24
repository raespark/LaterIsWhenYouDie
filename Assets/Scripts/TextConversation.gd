extends Node2D

# JSON file representing conversation
export (String, FILE, "*.json") var dialogueFile

# array of dialogue objects taken from the json file
var dialogue = []
# the current dialogue in the list of strings to be displayed
var current_dialogue = 0

onready var recieved_style = load("res://Scenes/ReceivedMessageStyle.tres")

onready var sent_style = load("res://Scenes/SentMessageStyle.tres")

onready var font = load("res://Scenes/textMessageFont.tres")

func _ready():
	dialogue = _parseJSON()
	var startingDialogue = dialogue[current_dialogue]
	_print_message(startingDialogue.text, startingDialogue.responseOptions)


func _parseJSON():
	var file = File.new()
	file.open(dialogueFile, File.READ)
	if file.get_error() != 0:
		print("FILE ERROR:")
		print(file.get_error())
		return []
	var jsonResult = JSON.parse(file.get_as_text())
	file.close()
	if jsonResult.error != 0:
		print("JSON ERROR:")
		print(jsonResult.error_string)
		print("ERROR ON LINE:")
		print(jsonResult.error_line)
		return []
	return jsonResult.result

func _print_message(text, options = false, recieved = true):
	var text_label = Label.new()
	text_label.text = text
	text_label.add_font_override("font", font)
	text_label.autowrap = true
	text_label.rect_min_size.x = 400
	if recieved:
		text_label.add_color_override("font_color", Color.black)
		text_label.size_flags_horizontal = 0
		text_label.add_stylebox_override("normal", recieved_style)
	else:
		text_label.size_flags_horizontal = Label.SIZE_SHRINK_END
		text_label.add_stylebox_override("normal", sent_style)
	$Scroll/MarginContainer/Texts.add_child(text_label)
	var bar = $Scroll.get_v_scrollbar()
	print(bar.value)
	print(bar.page)
	print(bar.max_value)
	if bar.value + bar.page >= bar.max_value :
		print("scrollin time")
		call_deferred("_scroll_to_bottom")
	if typeof(options) == TYPE_ARRAY:
		_enable_buttons()
		$Choices/ChoiceContainer/Option0.set_text(options[0].text)
		$Choices/ChoiceContainer/Option1.set_text(options[1].text)
		$Choices/ChoiceContainer/Option2.set_text(options[2].text)

func _scroll_to_bottom():
	print("SCROLL NOW")
	var bar = $Scroll.get_v_scrollbar()
	bar.value = bar.max_value

func _option_selected(option_index):
	_disable_buttons()
	var responses = dialogue[current_dialogue].responseOptions
	_print_message(responses[option_index].text, null, false)
	if responses[option_index].followUp != null:
			_print_message(responses[option_index].followUp)
	current_dialogue += 1
	if len(dialogue) > current_dialogue:
		_print_message(dialogue[current_dialogue].text, dialogue[current_dialogue].responseOptions)
	else: 
		_print_message("Go home.")

func _disable_buttons():
	$Choices/ChoiceContainer/Option0.disabled = true
	$Choices/ChoiceContainer/Option1.disabled = true
	$Choices/ChoiceContainer/Option2.disabled = true

func _enable_buttons():
	$Choices/ChoiceContainer/Option0.disabled = false
	$Choices/ChoiceContainer/Option1.disabled = false
	$Choices/ChoiceContainer/Option2.disabled = false

func _on_Option0_pressed():
	_option_selected(0)


func _on_Option1_pressed():
	_option_selected(1)


func _on_Option2_pressed():
	_option_selected(2)
