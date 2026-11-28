
extends Control

@onready var customer: TextureRect = $Customer
@onready var order_score: Label = $ScoreBar/OrderScore
@onready var roasting_score: Label = $ScoreBar/RoastingScore
@onready var cooking_score: Label = $ScoreBar/CookingScore
@onready var total_score_label: Label = $TotalScoreLabel
@onready var customer_comment: TextureRect = $CustomerComment
@onready var coins_reward: TextureRect = $CoinsReward
@onready var go_back_button: TextureButton = $GoBackButton

@export_group("Customer Textures")
@export var observe_texture: Texture2D
@export var happy_texture: Texture2D
@export var normal_texture: Texture2D
@export var angry_texture: Texture2D

@export_group("Customer Comment Textures")
@export var high_comment_texture: Texture2D
@export var medium_comment_texture: Texture2D
@export var low_comment_texture: Texture2D

@export_group("Coins Reward Textures")
@export var coins_high_texture: Texture2D
@export var coins_medium_texture: Texture2D
@export var coins_low_texture: Texture2D

@export_group("Angry Customer Adjustment")
@export var angry_width_ratio: float = 0.85
@export var angry_height_ratio: float = 1.03
@export var angry_offset: Vector2 = Vector2(0, -15)

@export_group("Demo Scores")
@export_range(0, 100) var demo_order_score: int = 96
@export_range(0, 100) var demo_roasting_score: int = 96
@export_range(0, 100) var demo_cooking_score: int = 96

@export_group("Animation")
@export var score_interval: float = 0.65

var base_customer_position: Vector2
var base_customer_size: Vector2
var scoring_sequence: int = 0
var scoring_finished: bool = false


func _ready() -> void:
	go_back_button.hide()
	go_back_button.disabled = true
	coins_reward.hide()
	customer_comment.hide()

	go_back_button.pressed.connect(_on_go_back_pressed)

	await get_tree().process_frame

	base_customer_position = customer.position
	base_customer_size = customer.size

	show_customer("observe")
	start_scoring()


func show_customer(state: String) -> void:
	customer.position = base_customer_position
	customer.size = base_customer_size

	match state:
		"observe":
			customer.texture = observe_texture

		"happy":
			customer.texture = happy_texture

		"normal":
			customer.texture = normal_texture

		"angry":
			customer.texture = angry_texture

			customer.size = Vector2(
				base_customer_size.x * angry_width_ratio,
				base_customer_size.y * angry_height_ratio
			)

			customer.position = (
				base_customer_position + angry_offset
			)


func reset_score_display() -> void:
	order_score.text = "--"
	roasting_score.text = "--"
	cooking_score.text = "--"

	total_score_label.text = ""
	total_score_label.hide()

	customer_comment.hide()
	coins_reward.hide()

	scoring_finished = false

	go_back_button.disabled = true
	go_back_button.hide()


func start_scoring() -> void:
	scoring_sequence += 1
	var current_sequence: int = scoring_sequence

	reset_score_display()
	show_customer("observe")

	# 1. Order Station
	await get_tree().create_timer(score_interval).timeout
	if current_sequence != scoring_sequence:
		return

	order_score.text = str(demo_order_score)

	# 2. Roasting Station
	await get_tree().create_timer(score_interval).timeout
	if current_sequence != scoring_sequence:
		return

	roasting_score.text = str(demo_roasting_score)

	# 3. Cooking Station
	await get_tree().create_timer(score_interval).timeout
	if current_sequence != scoring_sequence:
		return

	cooking_score.text = str(demo_cooking_score)

	# 4. Final Result
	await get_tree().create_timer(score_interval).timeout
	if current_sequence != scoring_sequence:
		return

	show_final_score()


func show_final_score() -> void:
	var total: int = roundi(
		(
			demo_order_score
			+ demo_roasting_score
			+ demo_cooking_score
		) / 3.0
	)

	total_score_label.text = "Totally %d !" % total
	total_score_label.show()

	if total >= 90:
		show_customer("happy")
		customer_comment.texture = high_comment_texture
		coins_reward.texture = coins_high_texture

	elif total >= 70:
		show_customer("normal")
		customer_comment.texture = medium_comment_texture
		coins_reward.texture = coins_medium_texture

	else:
		show_customer("angry")
		customer_comment.texture = low_comment_texture
		coins_reward.texture = coins_low_texture

	customer_comment.show()
	coins_reward.show()

	scoring_finished = true

	go_back_button.disabled = false
	go_back_button.show()


func _on_go_back_pressed() -> void:
	if not scoring_finished:
		return

	go_back_button.disabled = true

	# Temporary standalone Demo behavior.
	# Workbench navigation will be integrated later.
	get_tree().reload_current_scene()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				show_customer("observe")

			KEY_2:
				show_customer("happy")

			KEY_3:
				show_customer("normal")

			KEY_4:
				show_customer("angry")

			KEY_SPACE:
				start_scoring()
