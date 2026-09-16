extends SceneTree
var world: Node
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	world = load("res://sprites/world.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await create_timer(2.0).timeout
	var controller = world.get_node("Bird/AIController2D")
	var lab = world.get_node("ObservationLab")
	assert(controller.observation_snapshot().target != null)
	lab._toggle_pause()
	var before: Vector2 = world.get_node("Bird/CharacterBody2D").position
	await create_timer(0.2, true).timeout
	assert(before == world.get_node("Bird/CharacterBody2D").position)
	lab._toggle_slow()
	assert(Engine.time_scale == 0.25)
	lab._toggle_pause()
	lab._toggle_mode()
	assert(not world.demo_ai)
	lab._toggle_mode()
	assert(world.demo_ai)
	lab._toggle_slow()
	world.get_node("Bird").die()
	await create_timer(0.2).timeout
	assert(not world.get_node("Bird").dead)
	lab.geometry = false
	lab.heights = false
	lab.velocity = false
	await process_frame
	lab.geometry = true
	lab.heights = true
	lab.velocity = true
	await create_timer(0.6).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/flappy-master.png")
	print("PASS: target, pause, slow motion, control switching, death/reset, overlay toggles")
	quit()
