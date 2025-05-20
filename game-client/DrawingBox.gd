extends SubViewportContainer

signal send_message

var _pen : Sprite2D = null
var _cursor : Sprite2D = null
var _prev_mouse_pos = Vector2()
var history = []
var current_index : int

enum TOOL_TYPES{
	ERASER,
	PENCIL,
	TEXT
}
var active_tool = TOOL_TYPES.PENCIL
var tool_input_keys = {
	TOOL_TYPES.ERASER:"eraser",
	TOOL_TYPES.PENCIL:"pencil",
	TOOL_TYPES.TEXT:"text",
}

@onready var viewport : SubViewport = $SubViewport
@onready var cursor : Sprite2D = $Cursor

func _ready():
	_pen = Sprite2D.new()
	viewport.add_child(_pen)
	_pen.connect("draw", _on_draw)
	
	_cursor = Sprite2D.new()
	_cursor.connect("draw", _on_draw)
	_cursor.hide()
	add_child(_cursor)

func _process(delta):
	_pen.queue_redraw()
	_cursor.queue_redraw()

func _on_draw():
	var mouse_pos = get_local_mouse_position()
	
	if !_pen: return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _prev_mouse_pos != null:
			match active_tool:
				TOOL_TYPES.PENCIL:
					_pen.draw_line(mouse_pos, _prev_mouse_pos, Color(0,0,0),3)
				TOOL_TYPES.ERASER:
					_pen.draw_line(mouse_pos, _prev_mouse_pos, Color(.95,.95,.95),4)
		_prev_mouse_pos = mouse_pos
	else:
		_prev_mouse_pos = null

	if !_cursor: return
	match active_tool:
		TOOL_TYPES.PENCIL:
			_cursor.draw_circle(mouse_pos, 1.5, Color(0,0,0))
		TOOL_TYPES.ERASER:
			_cursor.draw_circle(mouse_pos, 2.5, Color(0,0,0))
			_cursor.draw_circle(mouse_pos, 1.5, Color(.95,.95,.95) )

func switch_tool(tool_type):
	active_tool = tool_type

func _input(event):
	for input_key in tool_input_keys:
		if event.is_action_pressed(tool_input_keys[input_key]):
			switch_tool(input_key)

func _on_SendMessage_pressed():
	var img = viewport.get_texture().get_image()
	img.flip_y()
	emit_signal("send_message", img)
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	$SubViewport/Timer.start()
	


func _on_Timer_timeout():
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
