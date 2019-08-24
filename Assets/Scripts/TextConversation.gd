extends Node2D

# JSON file representing conversation
export (String, FILE, "*.json") var dialogueFile

# array of dialogue objects taken from the json file
var dialogue = []
# the current dialogue in the list of strings to be displayed
var current_dialogue = 0

onready var typing_scene = load("res://Scenes/Typing.tscn")
onready var typing_instance = typing_scene.instance()

onready var recieved_style = load("res://Scenes/ReceivedMessageStyle.tres")

onready var sent_style = load("res://Scenes/SentMessageStyle.tres")

onready var font = load("res://Scenes/textMessageFont.tres")

var message

var isFollowup = false


func _ready():
	dialogue = _parseJSON()
	message = dialogue[current_dialogue]
	_print_message(message.text, message.responseOptions, true)

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
	if typeof(options) == TYPE_ARRAY:
		_enable_buttons()
		$Choices/ChoiceContainer/Option0.set_text(options[0].text)
		$Choices/ChoiceContainer/Option1.set_text(options[1].text)
		$Choices/ChoiceContainer/Option2.set_text(options[2].text)

func _show_typing():
	$Scroll/MarginContainer/Texts.add_child(typing_instance)
	$TypingTimer.start()

func _stop_typing():
	$Received.play()
	$Scroll/MarginContainer/Texts.remove_child(typing_instance)
	_print_message(message.text, message.responseOptions, true)
	if isFollowup:
		isFollowup = false
		current_dialogue += 1
		if len(dialogue) > current_dialogue:
			message = dialogue[current_dialogue]
			_show_typing()
		else: 
			message = {"text": "Go Away.", "responseOptions": null}
			_show_typing()

func _option_selected(option_index):
	$Sent.play()
	_disable_buttons()
	var responses = dialogue[current_dialogue].responseOptions
	_print_message(responses[option_index].text, null, false)
	if responses[option_index].followUp != null:
			isFollowup = true
			message = {"text": responses[option_index].followUp, "responseOptions": null}
			_show_typing()
			return
	current_dialogue += 1
	if len(dialogue) > current_dialogue:
		message = dialogue[current_dialogue]
		_show_typing()
	else: 
		message = {"text": "Go Away.", "responseOptions": null}
		_show_typing()

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
