extends HBoxContainer
class_name AdvancedActionContainer

var actionDisplay = [
	{
		"name" = "BezierTo",
		"getAction" = func():return Actions.BezierTo.new(Vector2(200,50),Vector2(200,100),Vector2(100,300),1.0),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size ,

	},
	{
		"name" = "Action Sequence",
		"getAction" = func():
			var actionMove = Actions.MoveBy.new(Vector2(0,300),0.5)
			var actionScale = Actions.ScaleTo.new(0.5,0.2)
			var actionRotate = Actions.RotateBy.new(180,0.2)
			return Actions.Seq.new([actionMove,actionScale,actionScale,actionRotate]),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size 
			info.target.scale = Vector2(1,1) 
			info.target.rotation_degrees = 0,
	},
	{
		"name" = "Action Merge",
		"getAction" = func():
			var actionMove = Actions.MoveBy.new(Vector2(0,300),1.0)
			var actionScale = Actions.ScaleTo.new(0.5,1.0)
			var actionRotate = Actions.RotateBy.new(180,1.0)
			return Actions.Merge.new([actionMove,actionScale,actionScale,actionRotate]),
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			info.target.position = info.pos *info.panel.size 
			info.target.scale = Vector2(1,1) 
			info.target.rotation_degrees = 0,
	},
	{
		"name" = "Action Repeat",
		"getAction" = func():
			var actionMove1 = Actions.MoveBy.new(Vector2(0,300),0.5)
			var actionMove2 = Actions.MoveBy.new(Vector2(0,-300),0.5)
			var seq = Actions.Seq.new([actionMove1,actionMove2])
			return Actions.Repeat.new(seq) ,
		"pos" = Vector2(0.5,0.2),
		"reset" = func(info):
			var manager = get_tree().get_root().find_child("ActionManager",true,false)
			manager.stopActionByNode(info.target)
			info.target.position = info.pos *info.panel.size ,
	},
	{
		"name" = "Action Delay",
		"getAction" = func():
			var actionDelay = Actions.Delay.new(0.5,func(): 
				# do sth after 0.5s 
				print("do sth while delay 0.5 s")) 
			var actionRotate = Actions.RotateBy.new(180,1.0)
			return Actions.Seq.new([actionDelay,actionRotate]),

		"pos" = Vector2(0.5,0.5),
		"reset" = func(info):
			info.target.rotation_degrees = 0,
	},
	{
		"name" = "Action WordDisplay",
		"getAction" = func():
			return Actions.WordDisplay.new(0.1,"Word Display Text ...") ,

		"pos" = Vector2(0.5,0.5),
		"reset" = func(info):
			var manager = get_tree().get_root().find_child("ActionManager",true,false)
			manager.stopActionByNode(info.target),
	},
	{
		"name" = "Action Blink",
		"getAction" = func():
			return Actions.Blink.new(0.2) ,
		"pos" = Vector2(0.5,0.5),
		"reset" = func(info):
			var manager = get_tree().get_root().find_child("ActionManager",true,false)
			manager.stopActionByNode(info.target)
			info.target.modulate = Color(1,1,1,1),
	},
	{
		"name" = "Action Schedule",
		"getAction" = func():
			return Actions.Schedule.new(0.2,func(p): 
				p.count+=1
				print("do sth while schedule count = ",p.count),{"count" = 0}) ,

		"pos" = Vector2(-0.5,-0.5),
		"reset" = func(info):
			var manager = get_tree().get_root().find_child("ActionManager",true,false)
			manager.stopActionByNode(info.target),
	}
]# Called when the node enters the scene tree for the first time.
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
	
	if info.name == "Action WordDisplay":
		var words = Label.new()
		words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		panel.add_child(words)
		info.target = words 

func initPanel():
	for info in actionDisplay:
		var panel = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.x = get_viewport_rect().size.x/len(actionDisplay)-5
		panel.custom_minimum_size.y = get_viewport_rect().size.y-50
		self.add_child(panel)
		setPanel(panel,info)
