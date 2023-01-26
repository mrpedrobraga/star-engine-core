extends Control

@export var source : TextureRect
@export var viewport : SubViewport

@export var initial_state : Texture2D

var no = false

func _ready():
	source.texture = ImageTexture.create_from_image(initial_state.get_image())

var t = 0.
func _physics_process(delta):
	
	await RenderingServer.frame_post_draw
	t += delta;
	
	if t > 0.02:
		t = 0
		#update()

func update():
	source.texture = ImageTexture.create_from_image(viewport.get_texture().get_image())
