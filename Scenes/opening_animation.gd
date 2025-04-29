extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skip_button: Sprite2D = $CanvasLayer/SkipButton
@onready var skip_button_timer: Timer = $SkipButtonTimer
@onready var hand: AnimatedSprite2D = $Wizard/Hand
@onready var start_button_timer: Timer = $StartButtonTimer
@onready var start_button: Sprite2D = $StartButton
@onready var title_card_overlay: Sprite2D = $TitleCard/TitleCardOverlay


var cutscene = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("title_card")

func _game_start():
	get_tree().change_scene_to_file("res://instruction_screen.tscn")
	

func _wizard_convo():
	animation_player.play("wizard_convo")

func _hex_and_launch():
	animation_player.play("hex_and_launch")
	


func _cast():
	hand.play("cast")


func _unhandled_input(event: InputEvent) -> void:
	if !cutscene and start_button_timer.is_stopped():
		start_button.visible = false
		cutscene = true
		animation_player.play("wizard_approach")
		skip_button_timer.start()
	if event.is_action_pressed("enter") and cutscene:
		_game_start()
	if skip_button_timer.is_stopped() and cutscene:
		skip_button.visible = true
		skip_button_timer.start()

func _on_skip_button_timer_timeout() -> void:
	skip_button.visible = false


func _on_start_button_timer_timeout() -> void:
	start_button.visible = true
