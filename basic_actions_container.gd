extends HBoxContainer
class_name BasicActionContainer
var actionDisplay = [
	{
		"name" = "MoveBy",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,

	},
	{
		"name" = "MoveTo",
		"getAction" = func():return Actions.MoveTo.new(Vector2(0,300),1.0),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,
	},
	{
		"name" = "RotateBy",
		"getAction" = func():return Actions.RotateBy.new(90,1.0),
		"pos" = Vector2(0.5,0.5),
	},
	{
		"name" = "RotateTo",
		"getAction" = func():return Actions.RotateTo.new(90,1.0),
		"pos" = Vector2(0.5,0.5),
		"reset" = func(info):
			info.target.rotation_degrees = 0,
	},
	{
		"name" = "ScaleBy",
		"getAction" = func():return Actions.ScaleBy.new(0.8,0.5),
		"pos" = Vector2(0.5,0.5),
#		"reset" = func(info):
#			info.target.scale = Vector2(1,1),
	},
	{
		"name" = "ScaleTo",
		"getAction" = func():return Actions.ScaleTo.new(0.5,0.5),
		"pos" = Vector2(0.5,0.5),
		"reset" = func(info):
			info.target.scale = Vector2(1,1),
	},
	{
		"name" = "FadeIn",
		"getAction" = func():return Actions.FadeIn.new(0.5),
		"pos" = Vector2(0.5,0.5),
		"reset" = func(info):
			info.target.modulate.a = 1.0,
	},
	{
		"name" = "FadeOut",
		"getAction" = func():return Actions.FadeOut.new(0.5),
		"pos" = Vector2(0.5,0.5),
		"reset" = func(info):
			info.target.modulate.a = 0.0,
	},
]
# Called when the node enters the scene tree for the first time.
func _ready():
	initPanel()
	Actions.Delay.new(0.1,func():
		runActions()).run(self)
	
func runActions():
	for info in actionDisplay:
		info.target.visible = true
		info.target.position = info.pos *info.panel.size 
		if info.has("reset") : info.reset.call(info)
		info.getAction.call().run(info.target)
		
		
func setPanel(panel,info):
	var sprite = Sprite2D.new()
	sprite.texture = load("res://icon.png")
	sprite.visible = false
	panel.add_child(sprite)
	
	var label = Label.new()
	label.text = info.name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_vertical = Control.SIZE_EXPAND
	panel.add_child(label)
	
	var btn = Button.new()
	btn.text = "run one more"
	btn.size_flags_vertical = Control.SIZE_SHRINK_END
	btn.custom_minimum_size.y = 100

	btn.pressed.connect(func():
		if info.has("reset") : info.reset.call(info)
		var action = info.getAction.call()
		# runActions by use  action.run(node)
		action.run(info.target))
	panel.add_child(btn)


	info.target = sprite 
	info.panel = panel 


func initPanel():
	for info in actionDisplay:
		var panel = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.x = get_viewport_rect().size.x/len(actionDisplay)-5
		panel.custom_minimum_size.y = get_viewport_rect().size.y-50
		self.add_child(panel)
		setPanel(panel,info)
