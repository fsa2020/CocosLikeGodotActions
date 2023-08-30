extends HBoxContainer
class_name EaseActionContainer
var actionDisplay = [
	{
		"name" = "NoEase",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,

	},
	{
		"name" = "EaseInQuad",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0).easeInQuad(),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,

	},
	{
		"name" = "EaseOutQuad",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0).easeOutQuad(),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,

	},
	{
		"name" = "EaseInOutQuad",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0).easeInOutQuad(),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,
	},
	{
		"name" = "EaseInOutCubic",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0).easeInOutCubic(),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,
	},
	{
		"name" = "EaseInOutSine",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0).easeInOutSine(),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,
	},
	{
		"name" = "EaseInOutExpo",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0).easeInOutExpo(),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,
	},
	{
		"name" = "EaseInOutCirc",
		"getAction" = func():return Actions.MoveBy.new(Vector2(0,300),1.0).easeInOutCirc(),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,
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
	sprite.texture = load("res://icon.svg")
	sprite.visible = false
	panel.add_child(sprite)
	
	var label = Label.new()
	label.text = info.name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_vertical = Control.SIZE_EXPAND
	panel.add_child(label)
	
	var btn = Button.new()

	btn.size_flags_vertical = Control.SIZE_SHRINK_END
	btn.custom_minimum_size.y = 100
	
	if info.name == "NoEase":
		btn.text = "run all"
		btn.pressed.connect(runActions)
	else:
		btn.text = "run one more"
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
