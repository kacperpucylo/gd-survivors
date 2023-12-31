extends CharacterBody2D

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent

var number_colliding_bodies = 0
var base_speed = 0

func _ready():
	base_speed = velocity_component.max_speed

	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_display()

func _process(_delta):
	var direction = get_movement_vector().normalized()
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)

	if direction.x != 0 || direction.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
	
	var move_sign = sign(direction.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)

func check_deal_damage() -> void:
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	health_component.damage(1)
	damage_interval_timer.start()

func update_health_display():
	health_bar.value = health_component.get_health_percent()

func on_body_entered(_other_body: Node2D) -> void:
	number_colliding_bodies += 1
	check_deal_damage()

func on_body_exited(_other_body: Node2D) -> void:
	number_colliding_bodies -= 1

func on_damage_interval_timer_timeout() -> void:
	check_deal_damage()

func on_health_changed() -> void:
	GameEvents.emit_player_damaged()
	update_health_display()
	$HitRandomStreamPlayer.play_random()

func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if (ability_upgrade is Ability):
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * .1)
