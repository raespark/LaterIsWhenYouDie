extends Node2D

# JSON file representing conversation
export (String, FILE, "*.json") var dialogueFile

#object of all paths
var all_dialogue
# array of dialogue objects taken from the json file
var dialogue = []
# the current dialogue in the list of strings to be displayed
var current_dialogue = 0

onready var typing_scene = load("res://Scenes/Typing.tscn")
onready var typing_instance = typing_scene.instance()

onready var recieved_style = load("res://Scenes/ReceivedMessageStyle.tres")

onready var sent_style = load("res://Scenes/SentMessageStyle.tres")

onready var font = load("res://Scenes/textMessageFont.tres")
onready var coded_font = load("res://Scenes/codedMessageFont.tres")

var message

var isFollowup = false

func _ready():
	all_dialogue = _parseJSON()
	dialogue = all_dialogue.get("main")
	#message = dialogue[current_dialogue]
	#_print_message(message.text, message.responseOptions, true)
	show_message(dialogue[current_dialogue])

func show_message(message):
	var text = message.get("text")
	var options = message.get("responseOptions")
	var waitDuration = message.get("waitTime", 1.0)
	if (waitDuration > 0):
		$TypingTimer.wait_time = waitDuration;
		$TypingTimer.start()
		if (text != null):
			$Scroll/MarginContainer/Texts.add_child(typing_instance)
		yield($TypingTimer, "timeout")
		if (text != null):
			$Scroll/MarginContainer/Texts.remove_child(typing_instance)
	_print_message(message.get("text"), message.get("responseOptions"), true)
	if (message.get("responseOptions") == null):
		_queue_next_message()

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

func _print_message(text, options = null, recieved = true):
	if options != null:
		_enable_buttons()
		$Choices/ChoiceContainer/Option0.set_text(options[0].text)
		$Choices/ChoiceContainer/Option1.set_text(options[1].text)
		$Choices/ChoiceContainer/Option2.set_text(options[2].text)
	if text == null:			
		return
	var text_label = Label.new()
	text_label.text = text
	text_label.autowrap = true
	text_label.rect_min_size.x = 400
	if recieved:
		$Received.play()
		text_label.add_font_override("font", coded_font)
		text_label.uppercase = true
		text_label.add_color_override("font_color", Color.black)
		text_label.size_flags_horizontal = 0
		text_label.add_stylebox_override("normal", recieved_style)
	else:
		$Sent.play()
		text_label.add_font_override("font", font)
		text_label.size_flags_horizontal = Label.SIZE_SHRINK_END
		text_label.add_stylebox_override("normal", sent_style)
	$Scroll/MarginContainer/Texts.add_child(text_label)

func _option_selected(option_index):
	_disable_buttons()
	var responses = dialogue[current_dialogue].get("responseOptions")
	var chosenResponse = responses[option_index]
	_print_message(chosenResponse.get("text"), null, false)
	var gotoBranch = chosenResponse.get("gotoBranch")
	if (gotoBranch != null):
		dialogue = all_dialogue.get(gotoBranch)
		current_dialogue = -1
	_queue_next_message()

func _queue_next_message():
	current_dialogue += 1
	if len(dialogue) > current_dialogue:
		message = dialogue[current_dialogue]
		show_message(message)
	else: 
		message = {"text": "Go Away.", "responseOptions": null}
		show_message(message)

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
