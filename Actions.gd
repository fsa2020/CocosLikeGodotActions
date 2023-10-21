extends Node

class Action:
	var duration	:float = 0
	var curTime		:float = 0
	# -1 ： not start
	var curProgress	:float = -1

	var node
	var manager
	var onFinish
	var cbParams
	var easeFunc
	## override init 
	## finishCallBack need to be a lambda
	func _init(time,finishCallBack=null,params = {}):
		duration = time
		onFinish = finishCallBack
		cbParams = params
		
	func getDefaultManager():
		var root = node.get_tree().get_root()
		var default = root.find_child("ActionManager",true,false)
		if default == null:
			default = ActionManager.new()
			root.add_child(default) 
			default.name = "ActionManager"
			default.owner = root
		return default

	func setActionManeger(tarManager):
		manager = tarManager
		
	func addToActionManeger():
		if manager == null:
			manager = getDefaultManager()
		manager.add(self)
	func isRunning():
		return curProgress >=0 and curProgress<1
		
	func isRunOver():
		return curProgress == 1
		
	func isToRun():
		return curProgress == -1
	
	func run(target):
		curProgress = 0
		curTime = 0
		setNode(target)
		addToActionManeger()
		return self
		
	func setNode(target):
		node = target
		
	func stop():
		curProgress = 1
		onRunOver()
	
	
	# p -> (0,1]
	# override this: do lerp or sth
	func updateProgress(p):
		pass

	func update(delta):
		if isRunning():
			curTime+=delta
			curProgress = min(curTime/duration,1)
			if easeFunc != null:
				curProgress = easeFunc.call(curProgress)
			updateProgress(curProgress)
		if isRunOver():
			onRunOver()
			finishCall()
			
	func onRunOver():
		pass
		
	func finishCall():
		if onFinish != null: 
			if cbParams.is_empty():
				onFinish.call()
			else:
				onFinish.call(cbParams)

	##-------------------------------- ease funcs ----------------------------------
	func easeInQuad():
		easeFunc = func(p):
			return p * p
		return self

	func easeOutQuad():
		easeFunc = func(p):
			return -p * (p - 2)
		return self
	func easeInOutQuad():
		easeFunc = func(p):
			if p < 0.5:
				return 2 * p * p
			else:
				return (-2 * p * p) + (4 * p) - 1
		return self

	func easeInCubic():
		easeFunc = func(p):
			return p * p * p
		return self

	func easeOutCubic():
		easeFunc = func(p):
			var f = p - 1
			return f * f * f + 1
		return self
	func easeInOutCubic():
		easeFunc = func(p):
			if p < 0.5:
				return 4 * p * p * p
			else:
				var f = ((2 * p) - 2)
				return 0.5 * f * f * f + 1
		return self
		
	func easeInQuart():
		easeFunc = func(p):
			return p * p * p * p
		return self
		
	func easeOutQuart():
		easeFunc = func(p):
			var f = p - 1
			return f * f * f * (1 - p) + 1
		return self
	
	func easeInOutQuart():
		easeFunc = func(p):
			if p < 0.5:
				return 8 * p * p * p * p
			else:
				var f = p - 1
				return -8 * f * f * f * f + 1
		return self
		
	func easeInSine():
		easeFunc = func(p):
			return 1 - cos((p * PI) / 2)
		return self
		
	func easeOutSine():
		easeFunc = func(p):
			return sin((p * PI) / 2)
		return self
		
	func easeInOutSine():
		easeFunc = func(p):
			return -0.5 * (cos(PI * p) - 1)
		return self
		
	func easeInExpo():
		easeFunc = func(p):
			return pow(2, 10 * (p - 1))
		return self
		
	func easeOutExpo():
		easeFunc = func(p):
			return -pow(2, -10 * p) + 1
		return self
		
	func easeInOutExpo():
		easeFunc = func(p):
			if p < 0.5:
				return 0.5 * pow(2, (20 * p) - 10)
			else:
				return -0.5 * pow(2, (-20 * p) + 10) + 1
		return self
		
	func easeInCirc():
		easeFunc = func(p):
			return 1 - sqrt(1 - (p * p))
		return self
		
	func easeOutCirc():
		easeFunc = func(p):
			return sqrt((2 - p) * p)
		return self
		
	func easeInOutCirc():
		easeFunc = func(p):
			if p < 0.5:
				return 0.5 * (1 - sqrt(1 - 4 * (p * p)))
			else:
				return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1)
		return self
		
class MoveTo:
	extends Action
	var tarPos
	var orgPos
	func _init(pos,time,finishCallBack=null, params = {}):
		tarPos = pos
		duration = time
		onFinish = finishCallBack
		cbParams = params
		
	func updateProgress(p):
		if orgPos == null:
			orgPos = Vector2(node.position.x,node.position.y)
		node.position = orgPos.lerp(tarPos,p)
	
	func onRunOver():
		orgPos = null

class MoveBy:
	extends Action
	var tarPos
	func _init(pos,time,finishCallBack=null, params = {}):
		tarPos = pos
		duration = time
		onFinish = finishCallBack
		cbParams = params
	
	var pre = Vector2(0,0)
	func updateProgress(p):
		var cur = Vector2(0,0).lerp(tarPos,p)
		node.position += cur-pre
		pre = cur
		
	func onRunOver():
		pre = Vector2(0,0)

class RotateTo:
	extends Action
	var tarDegree
	var orgDegree
	func _init(degree,time,finishCallBack=null,params = {}):
		tarDegree = degree
		duration = time
		onFinish = finishCallBack
		cbParams = params

	func updateProgress(p):
		if orgDegree == null:
			orgDegree = node.rotation_degrees
		node.rotation_degrees  = lerp(orgDegree,float(tarDegree),p)
	func onRunOver():
		orgDegree = null
		
class RotateBy:
	extends Action
	var tarDegree
	func _init(degree,time,finishCallBack=null,params = {}):
		tarDegree = degree
		duration = time
		onFinish = finishCallBack
		cbParams = params

	var pre = 0.0
	func updateProgress(p):
		var cur = lerp(0.0,float(tarDegree),p)
		node.rotation_degrees += cur-pre
		pre = cur
		
	func onRunOver():
		pre = 0.0

class ScaleTo:
	extends Action
	var tarScale
	var orgScale
	func _init(scale,time,finishCallBack=null,params = {}):
		if typeof(scale) == TYPE_INT or  typeof(scale) == TYPE_FLOAT:
			tarScale = Vector2(scale,scale)
		else:
			tarScale = scale
		duration = time
		onFinish = finishCallBack
		cbParams = params

	func updateProgress(p):
		if orgScale == null:
			orgScale = Vector2(node.scale.x,node.scale.y)
		node.scale = orgScale.lerp(tarScale,p)
	
	func onRunOver():
		orgScale = null
		
class ScaleBy:
	extends Action
	var tarScale
	var orgScale
	func _init(scale,time,finishCallBack=null,params={}):
		if typeof(scale) == TYPE_INT or  typeof(scale) == TYPE_FLOAT:
			tarScale = Vector2(scale,scale)
		else:
			tarScale = scale

		duration = time
		onFinish = finishCallBack
		cbParams = params

	func run(traget):
		tarScale = tarScale*traget.scale
		super.run(traget)
		
	func updateProgress(p):
		if orgScale == null:
			orgScale = Vector2(node.scale.x,node.scale.y)
		node.scale = orgScale.lerp(tarScale,p)
		
	func onRunOver():
		orgScale = null
		
class FadeTo:
	extends Action
	var tarA
	var orgA
	func _init(a,time,finishCallBack=null,params = {}):
		tarA = float(a)
		duration = time
		onFinish = finishCallBack
		cbParams = params

	func updateProgress(p):
		if orgA == null:
			orgA = node.modulate.a
		node.modulate.a = lerp(orgA,tarA,p)
	
	func onRunOver():
		orgA = null
		
class FadeIn:
	extends FadeTo
	func _init(time,finishCallBack=null,params = {}):
		tarA = 0.0
		duration = time
		onFinish = finishCallBack
		cbParams = params
		
class FadeOut:
	extends FadeTo
	func _init(time,finishCallBack=null,params = {}):
		tarA = 1.0
		duration = time
		onFinish = finishCallBack
		cbParams = params


class TintTo:
	extends Action
	var tarColor
	var orgColor
	func _init(col,time,finishCallBack=null, params = {}):
		tarColor = col
		duration = time
		onFinish = finishCallBack
		cbParams = params
		
	func updateProgress(p):
		if orgColor == null:
			orgColor = Color(node.modulate.r,node.modulate.g,node.modulate.b,node.modulate.a)
		node.modulate = orgColor.lerp(tarColor,p)
	
	func onRunOver():
		orgColor = null

class TintBy:
	extends Action
	var tarColor
	func _init(col,time,finishCallBack=null, params = {}):
		tarColor = col
		duration = time
		onFinish = finishCallBack
		cbParams = params
	
	var pre = Color(0,0,0,0)
	func updateProgress(p):
		var cur = Color(0,0,0,0).lerp(tarColor,p)
		node.modulate += cur-pre
		pre = cur
		
	func onRunOver():
		pre = Color(0,0,0,0)
		

class BezierTo:
	extends Action
	var end
	var control1
	var control2
	var orgPos
	func _init(control1Pos,control2Pos,endPos,time,finishCallBack=null,params = {}):
		end = endPos
		control1 = control1Pos
		control2 = control2Pos
		duration = time
		onFinish = finishCallBack
		cbParams = params
		
	func updateProgress(p):
		if orgPos == null:
			orgPos = Vector2(node.position.x,node.position.y)
		var pos = bezier(orgPos,control1,control2,end,p)
		node.position = pos

	
	func onRunOver():
		orgPos = null
		
	func bezier(p0,p1,p2,p3,t):
		var u = 1 - t
		var tt = t * t
		var uu = u * u
		var uuu = uu * u
		var ttt = tt * t
		var p = uuu * p0
		p += 3 * uu * t * p1
		p += 3 * u * tt * p2
		p += ttt * p3
		return p
	
class Seq:
	extends Action
	var actionList = []
	var progressList = []
	# -1 to run ; 0 running ; 1 run over
	var subActionStates = []
	var anum
	# action in list can be seq or merge or other
	func _init(list,finishCallBack=null, params = {}):
		duration = 0
		actionList = list
		anum = len(actionList)
		# init duration , progressList , subActionStates
		for subAction in actionList:
			duration += subAction.duration
			progressList.append(duration)
			subActionStates.append(-1)
			
		for i in range(len(progressList)):
			progressList[i] = progressList[i]/duration
			
		onFinish = finishCallBack
		cbParams = params
		
	func updateProgress(p):
		for i in range(anum):
			var subAction = actionList[i]
			var startProgress = 0 
			if i>0 : startProgress = progressList[i-1] 
				
			if subActionStates[i] == -1 :
			
				if startProgress<p:
					subActionStates[i] = 0

			if subActionStates[i] == 0 :

				var subProgress = (p-startProgress)/(progressList[i]-startProgress)
				
				subProgress = min(subProgress,1)
				subAction.updateProgress(subProgress)

				if subProgress == 1:
					subActionStates[i] = 1
					subAction.onRunOver()
					subAction.finishCall()

	func stop():
		curProgress = 1
		for subAction in actionList:
			subAction.stop()
			
	func setNode(target):
		node = target
		for subAction in actionList:
			subAction.setNode(target)
			
	func resetSubAct():
		subActionStates.fill(-1)
		for subAction in actionList:
			if subAction.has_method("resetSubAct"):
				subAction.resetSubAct()

class Merge:
	extends Action
	var actionList = []
	var subActionStates = []
	var progressList = []
	var anum

	func _init(list,finishCallBack=null ,params={}):
		duration = 0
		actionList = list
		anum = len(actionList)
		# init duration and progressList
		for subAction in actionList:
			duration = max(duration,subAction.duration)
			progressList.append(subAction.duration)
			subActionStates.append(-1)
			
		for i in range(len(progressList)):
			progressList[i] = progressList[i]/duration
			
		onFinish = finishCallBack
		cbParams = params
				
	func updateProgress(p):
		for i in range(anum):
			var subAction = actionList[i]
			
			if subActionStates[i] == -1 :
					subActionStates[i] = 0

			if subActionStates[i] == 0 :
				var subProgress = p/progressList[i]
				subProgress = min(subProgress,1)
				subAction.updateProgress(subProgress)

				if subProgress == 1:
					subActionStates[i] = 1
					subAction.onRunOver()
					subAction.finishCall()

	func stop():
		curProgress = 1
		for subAction in actionList:
			subAction.stop()
			
	func setNode(target):
		node = target
		for subAction in actionList:
			subAction.setNode(target)
			
	func resetSubAct():
		subActionStates.fill(-1)
		for subAction in actionList:
			if subAction.has_method("resetSubAct"):
				subAction.resetSubAct()


class Repeat:
	extends Action
	var repeatAction
	var timeToRepeat
	
	func _init(repeatAct,times=-1,finishCallBack=null,params={}):
		duration = repeatAct.duration
		timeToRepeat = times
		repeatAction = repeatAct
		onFinish = finishCallBack
		cbParams = params
				
	func updateProgress(p):
		repeatAction.updateProgress(p)
		
	func update(delta):
		if isRunning():
			curTime+=delta
			curProgress = min(curTime/duration,1)
			updateProgress(curProgress)

		if isRunOver():
			repeatAction.onRunOver()
			repeatAction.finishCall()
			# repeat forever
			if timeToRepeat < 0:
				curProgress = 0
				curTime = 0
				if repeatAction.has_method("resetSubAct"):
					repeatAction.resetSubAct()
			# repeat continue   
			elif timeToRepeat > 0:
				curProgress = 0
				curTime = 0
				timeToRepeat -= 1
				if repeatAction.has_method("resetSubAct"):
					repeatAction.resetSubAct()
			# repeat over
			elif timeToRepeat == 0:
				onRunOver()
				finishCall()

	func run(target):
		timeToRepeat -= 1
		curProgress = 0
		node = target
		setNode(target)
		addToActionManeger()
		return self
		
	func setNode(target):
		node = target
		repeatAction.setNode(target)
		
	func stop():
		timeToRepeat = 0
		curProgress = 1
		repeatAction.stop()
		
class Delay:
	extends Action
	
	func _init(delayTime,finishCallBack=null ,params={}):
		duration = delayTime
		onFinish = finishCallBack
		cbParams = params

class Schedule:
	extends Repeat
	
	func _init(interval,finishCallBack=null,params={},times=-1):
		duration = interval
		timeToRepeat = times
		repeatAction = Actions.Delay.new(interval,finishCallBack,params)

class WordDisplay:
	extends Repeat
	## target need to be label or sth has text prop
	func _init(interval,words = "...",finishCallBack=null,params={}):
		duration = interval
		timeToRepeat = len(words)
		onFinish = finishCallBack
		cbParams = params
		
		var callBack = func(p):
			var s = p.words
			var c = min(len(s),1+len(s)-self.timeToRepeat)
			node.text = s.left(c)

		repeatAction = Actions.Delay.new(interval,callBack,{"words"=words})

class Blink:
	extends Repeat
	
	func _init(interval,finishCallBack=null,params={},times=-1):
		duration = interval
		timeToRepeat = times
		onFinish = finishCallBack
		cbParams = params

		repeatAction = Actions.Seq.new([
			Actions.TintBy.new(Color(0.5,0.5,0.5,0),interval/2),
			Actions.TintBy.new(Color(-0.5,-0.5,-0.5,0),interval/2),
		])

class Shake:
	extends Action
	var amplitude
	var rng = RandomNumberGenerator.new()	
	func _init(time,amp = Vector2(1,1),finishCallBack=null,params={}):
		duration = time
		onFinish = finishCallBack
		cbParams = params
		amplitude = amp

	var lastOffset = Vector2(0,0)
	func updateProgress(p):
		var l = smoothstep(0.1,0.5,1-p)
		var sigX = 1 if rng.randi()%2 == 0 else -1
		var sigY = 1 if rng.randi()%2 == 0 else -1
		var sX = rng.randf_range(amplitude.x*0.6,amplitude.x)*l*sigX
		var sY = rng.randf_range(amplitude.y*0.6,amplitude.y)*l*sigY
		node.position += Vector2(sX,sY)-lastOffset
		lastOffset =  Vector2(sX,sY)

	func onRunOver():
		lastOffset = Vector2(0,0)



