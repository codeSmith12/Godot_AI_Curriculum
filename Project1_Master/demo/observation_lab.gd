extends CanvasLayer
## Draw live observations in screen coordinates; never reimplement target selection.
const INK := Color("101d32")
const MUTED := Color("8fa6c1")
const CYAN := Color("48e2ee")
const GOLD := Color("ffd16b")
const PINK := Color("ff85bd")
const GREEN := Color("9dedaf")
var canvas: Control
var font: Font = ThemeDB.fallback_font
var overlay_enabled := true
var geometry := true
var heights := true
var velocity := true
var paused := false
var slow := false
var flap_flash := 0.0
var death_flash := 0.0
var previous_ms := 0
var mode_button: Button
var pause_button: Button
var slow_button: Button
@onready var world = get_parent()
@onready var bird = world.get_node("Bird/CharacterBody2D")
@onready var controller = world.get_node("Bird/AIController2D")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	canvas = Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	canvas.draw.connect(_draw_overlay)
	mode_button = _button("AI PILOT  /  switch to human", Vector2(1176, 132), _toggle_mode)
	pause_button = _button("Pause", Vector2(1176, 184), _toggle_pause, 130)
	slow_button = _button("Slow motion", Vector2(1316, 184), _toggle_slow, 138)
	_button("Restart episode", Vector2(1176, 236), _restart)
	_check("Observation overlay", 302, func(value): overlay_enabled = value)
	_check("Target + distance triangle", 342, func(value): geometry = value)
	_check("Bird + gap height rulers", 382, func(value): heights = value)
	_check("Velocity arrow", 422, func(value): velocity = value)
	world.get_node("Bird").flapped.connect(func(): flap_flash = 1.0)
	world.get_node("Bird").died.connect(func(): death_flash = 1.0)
	previous_ms = Time.get_ticks_msec()

func _button(text_value: String, position_value: Vector2, callback: Callable, width := 278.0) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = Vector2(width, 42)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 16)
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("263d59") if state == "normal" else Color("365575")
		style.set_corner_radius_all(8)
		button.add_theme_stylebox_override(state, style)
	canvas.add_child(button)
	button.pressed.connect(callback)
	return button

func _check(text_value: String, y: float, callback: Callable) -> void:
	var check := CheckButton.new()
	check.text = text_value
	check.position = Vector2(1170, y)
	check.size = Vector2(294, 36)
	check.button_pressed = true
	check.focus_mode = Control.FOCUS_NONE
	check.add_theme_font_size_override("font_size", 15)
	canvas.add_child(check)
	check.toggled.connect(callback)

func _toggle_mode() -> void:
	if world.external_training:
		return
	world.demo_ai = not world.demo_ai
	mode_button.text = "AI PILOT  /  switch to human" if world.demo_ai else "HUMAN  /  switch to AI"
	_restart()

func _toggle_pause() -> void:
	if world.external_training:
		return
	paused = not paused
	get_tree().paused = paused
	pause_button.text = "Resume" if paused else "Pause"

func _toggle_slow() -> void:
	if world.external_training:
		return
	slow = not slow
	Engine.time_scale = 0.25 if slow else 1.0
	slow_button.text = "Speed: 0.25×" if slow else "Slow motion"

func _restart() -> void:
	if not world.external_training:
		world.reset_game()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_P: _toggle_pause()
			KEY_O: overlay_enabled = not overlay_enabled
			KEY_R: _restart()
			KEY_TAB: _toggle_mode()

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	var real_delta := (now - previous_ms) / 1000.0
	previous_ms = now
	if not paused:
		flap_flash = maxf(0.0, flap_flash - real_delta * 3.0)
		death_flash = maxf(0.0, death_flash - real_delta * 1.2)
	mode_button.disabled = world.external_training
	pause_button.disabled = world.external_training
	slow_button.disabled = world.external_training
	canvas.queue_redraw()

func _text(at: Vector2, value: String, color := Color.WHITE, size := 16) -> void:
	canvas.draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _tag(at: Vector2, value: String, color: Color) -> void:
	var size := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	var origin := Vector2(clampf(at.x, 8, 1130 - size.x), clampf(at.y, 26, 630))
	canvas.draw_style_box(_box(Color("172b42")), Rect2(origin - Vector2(8, 19), size + Vector2(16, 10)))
	_text(origin, value, color)

func _box(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(7)
	return style

func _arrow(start: Vector2, end: Vector2, color: Color, width := 3.0) -> void:
	if start.distance_to(end) < 2:
		return
	canvas.draw_line(start, end, Color(0.05, 0.12, 0.2, 0.5), width + 3, true)
	canvas.draw_line(start, end, color, width, true)
	var direction := (end - start).normalized()
	canvas.draw_colored_polygon(PackedVector2Array([end, end - direction.rotated(0.48) * 14, end - direction.rotated(-0.48) * 14]), color)

func _ruler(x: float, y: float, color: Color) -> void:
	canvas.draw_line(Vector2(x, 8), Vector2(x, y), color, 2, true)
	for mark in range(0, int(maxf(0, y)), 25):
		canvas.draw_line(Vector2(x - 4, mark), Vector2(x + 4, mark), Color(color, 0.5), 1)
	canvas.draw_line(Vector2(x - 9, y), Vector2(x + 9, y), color, 3)

func _draw_overlay() -> void:
	var snapshot: Dictionary = controller.observation_snapshot()
	var position: Vector2 = bird.global_position
	var marker = snapshot.target
	if overlay_enabled:
		if heights:
			_ruler(42, position.y, GREEN)
			canvas.draw_dashed_line(Vector2(42, position.y), position, Color(GREEN, 0.8), 2, 6)
			_tag(Vector2(58, maxf(38, position.y * 0.5)), "BIRD HEIGHT", GREEN)
		if marker != null:
			var target: Vector2 = marker.global_position
			if geometry:
				var corner := Vector2(target.x, position.y)
				canvas.draw_colored_polygon(PackedVector2Array([position, corner, target]), Color(CYAN, 0.09))
				canvas.draw_dashed_line(position, corner, GOLD, 2.5, 9)
				canvas.draw_dashed_line(corner, target, PINK, 2.5, 9)
				_arrow(position, target, CYAN, 2.5)
				canvas.draw_arc(target, 23, 0, TAU, 48, CYAN, 3, true)
				canvas.draw_circle(target, 5, Color.WHITE)
				_tag(Vector2(target.x - 135, minf(target.y, position.y) - 58), "SELECTED GAP", CYAN)
				_tag((position + corner) * 0.5 + Vector2(-40, -12), "DISTANCE AHEAD", GOLD)
				_tag((corner + target) * 0.5 + Vector2(-145, 32), "GAP OFFSET", PINK)
			if heights:
				_ruler(minf(target.x + 75, 1118), target.y, Color(CYAN, 0.7))
				_tag(Vector2(minf(target.x + 88, 980), 54), "GAP HEIGHT*", CYAN)
		else:
			_tag(Vector2(400, 100), "NO PIPE — default target ahead", CYAN)
		if velocity:
			var end := position + Vector2(0, clampf(bird.velocity.y * 0.22, -145, 145))
			_arrow(position + Vector2(-32, 0), end + Vector2(-32, 0), Color.WHITE, 5)
			_tag(position + Vector2(-95, 65), "RISING" if bird.velocity.y < 0 else "FALLING", Color.WHITE)
		if flap_flash > 0:
			canvas.draw_arc(position, 28 + (1 - flap_flash) * 35, 0, TAU, 48, Color(GOLD, flap_flash), 4, true)

	# Opaque teaching panel and bottom strip stay readable over any game state.
	canvas.draw_rect(Rect2(1150, 0, 330, 740), INK)
	canvas.draw_rect(Rect2(0, 650, 1150, 90), Color("14263c"))
	canvas.draw_line(Vector2(1150, 0), Vector2(1150, 740), Color("304c69"), 2)
	_text(Vector2(1176, 35), "FLAPPY BIRD", MUTED, 14)
	_text(Vector2(1176, 70), "Observation Lab", Color.WHITE, 27)
	_text(Vector2(1176, 100), "Watch what the agent can see.", MUTED, 15)
	_text(Vector2(1176, 494), "DECISION", MUTED, 13)
	var ai_active: bool = world.demo_ai or world.external_training
	var action_label := "FLAP" if flap_flash > 0.45 else "COAST"
	_text(Vector2(1176, 529), action_label, GOLD if flap_flash > 0.45 else CYAN, 29)
	if ai_active and not world.external_training:
		var probability: float = world.last_probabilities[1]
		canvas.draw_rect(Rect2(1176, 546, 278, 8), Color("30445d"))
		canvas.draw_rect(Rect2(1176, 546, 278 * probability, 8), GOLD)
		_text(Vector2(1176, 578), "Flap probability  %d%%" % roundi(probability * 100), MUTED, 15)
	else:
		_text(Vector2(1176, 578), "Python controls" if world.external_training else "Press Space to flap", MUTED, 16)
	_text(Vector2(1176, 628), "Episode %d   ·   %.1f seconds" % [world.episodes, world.elapsed], Color.WHITE, 16)
	_text(Vector2(1176, 657), "Reward this run  %+.2f" % world.episode_reward, GREEN, 16)
	_text(Vector2(1176, 710), "P pause   ·   R reset   ·   Tab pilot", MUTED, 13)
	var colors := [GREEN, Color.WHITE, GOLD, PINK]
	var names := ["BIRD HEIGHT", "VERTICAL SPEED", "DISTANCE AHEAD", "GAP OFFSET"]
	for i in range(4):
		var x := 26.0 + i * 282
		_text(Vector2(x, 678), names[i], colors[i], 13)
		_text(Vector2(x, 711), "%+.2f" % snapshot.obs[i], Color.WHITE, 25)
	_text(Vector2(26, 733), "Normalized inputs  ·  *Gap height is a teaching guide; the policy receives the relative gap offset.", MUTED, 12)
	if paused:
		_tag(Vector2(490, 320), "PAUSED — inspect the observations", GOLD)
	if death_flash > 0:
		canvas.draw_style_box(_box(Color(0.35, 0.08, 0.15, death_flash)), Rect2(405, 18, 310, 44))
		_text(Vector2(424, 47), "EPISODE ENDED   ·   reward −1", Color(1, 0.8, 0.85, death_flash), 18)
