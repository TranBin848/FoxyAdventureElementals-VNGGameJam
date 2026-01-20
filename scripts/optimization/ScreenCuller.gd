class_name ScreenCuller
extends VisibleOnScreenEnabler2D

signal entered_screen
signal exited_screen

@export_category("Culling Settings")
## The size of the box. MUST be large enough to cover the Light's radius!
@export var cull_size: Vector2 = Vector2(128, 128)

@export_category("Optimization Targets")
## Drag a Node2D here (e.g., "Visuals" or "LightSource") to hide it completely when off-screen.
## This saves MASSIVE GPU power for Lights and Particles.
@export var visuals_node: Node2D

## If true, puts the Parent Node to sleep (Stops _process, _physics_process, and Collision).
## This saves CPU power.
@export var disable_parent_processing: bool = true

@export_category("Debugging")
@export var debug_mode: bool = false

# Cache the parent to avoid repeated get_parent() calls
var _parent: Node2D

func _ready() -> void:
	# 1. Setup the hitbox
	rect = Rect2(-cull_size / 2, cull_size)
	
	_parent = get_parent() as Node2D
	if not _parent:
		push_error("ScreenCuller must be a child of a Node2D.")
		return

	# 2. CRITICAL: This node must ALWAYS run so it can 'watch' for the camera.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 3. Connect signals
	screen_entered.connect(_on_screen_entered)
	screen_exited.connect(_on_screen_exited)
	
	# 4. Immediate check (if spawned off-screen)
	if not is_on_screen():
		_on_screen_exited()

func _on_screen_entered() -> void:
	if debug_mode: print("[%s] Waking Up!" % _parent.name)
	
	# 1. Restore Visuals (Turn Lights/Particles back ON)
	if visuals_node:
		visuals_node.visible = true
	
	# 2. Wake up Logic (Resume Scripts/Physics)
	if disable_parent_processing and _parent:
		_parent.process_mode = Node.PROCESS_MODE_INHERIT
	
	entered_screen.emit()

func _on_screen_exited() -> void:
	if debug_mode: print("[%s] Going to Sleep..." % _parent.name)
	
	# 1. Kill Visuals (Turn Lights/Particles OFF to save GPU)
	if visuals_node:
		visuals_node.visible = false
	
	# 2. Kill Logic (Pause Scripts/Physics to save CPU)
	if disable_parent_processing and _parent:
		_parent.process_mode = Node.PROCESS_MODE_DISABLED
		
	exited_screen.emit()

# Helper to see the box in the editor
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(rect, Color(1, 0, 0, 0.2), false)
