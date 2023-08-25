extends Node
class_name ActionManager
# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	## todo 
	clearActionDone()
	for a in actionList:
		if a.isRunning():
			# node has been free
			if a.node == null:
				a.curProgress = 1
			else:
				a.update(delta)
		

var actionList = []
## todo 
var nodeActionDict = {}
var actionNodeDict = {}
## to be optimize
func clearActionDone():

	var p = 0
	while(p<len(actionList)):
		var act =  actionList[p]
		if act.curProgress == 1:
			# clear actionList
			actionList.pop_at(p)
			# clear actionNodeDict
			actionNodeDict.erase(act)
			# clear nodeActionDict
			nodeActionDict[act.node].erase(act)
			if nodeActionDict[act.node].size()==0:
				nodeActionDict.erase(act.node)

		else:
			p+=1

func add(action):
	actionList.append(action)
	
	# node-actions one node can run multi actions
	if not nodeActionDict.has(action.node):
		nodeActionDict[action.node] = {}
	nodeActionDict[action.node][action] = true
	
	# action-node one action only acttatch to one node
	if not actionNodeDict.has(action):
		actionNodeDict[action] = {}
	actionNodeDict[action] = action.node

func getAllRunningActions():
	return actionList
	
func getAllRunningNodes():
	return nodeActionDict.keys()
	
func getRunningActionsByNode(node):
	if nodeActionDict.has(node):
		return nodeActionDict[node].keys()
	else:
		return []

## stop by set action.curProgress = 1
func stopActionByNode(node):
	var actions = getRunningActionsByNode(node)
	for a in actions:
		a.curProgress = 1
		
func stopActionByNodeWithFinishCall(node):
	var actions = getRunningActionsByNode(node)
	for a in actions:
		a.curProgress = 1
		a.finishCall()
		
func stopAllActions():
	for a in actionList:
		a.curProgress = 1
		
func stopAllActionsWithFinishCall():
	for a in actionList:
		a.curProgress = 1
		a.finishCall()
