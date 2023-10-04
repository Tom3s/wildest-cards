extends Node
class_name MatchEventListener

@onready var startButton: Button = %StartButton
@onready var playButton: Button = %PlayButton
@onready var playerList: RichTextLabel = %PlayerList

@onready var state: MatchStateMachine = %MatchStateMachine



func setup():
	playButton.disabled = true
	startButton.disabled = Network.userId != 1
	connectSignals()

func connectSignals():
	startButton.pressed.connect(startGame)
	playButton.pressed.connect(onPlayButton_pressed)

	Network.userListNeedsUpdate.connect(onNetwork_userListNeedsUpdate)
	get_tree().get_multiplayer().peer_disconnected.connect(onUserLeftServer)

func onPlayButton_pressed():
	rpc("incrementPlayerIndexForAll")
	await state.playerIndexIncremented
	print('[MatchEventListener.gd] Player index incremented; client: ', Network.userId)
	# playerList.setPlayers(state.playerNames, state.currentPlayerIndex)
	# rpc("setPlayerListForAll")
	# rpc("setPlayButtonEnabled")


@rpc("any_peer", "call_local", "reliable")
func incrementPlayerIndexForAll():
	state.incrementPlayerIndex()
	setPlayerListForAll()
	setPlayButtonEnabled()

@rpc("any_peer", "call_local", "reliable")
func setPlayerListForAll() -> void:
	playerList.setPlayers(state.playerNames, state.currentPlayerIndex)

func onNetwork_userListNeedsUpdate():
	state.playerIds.clear()
	state.playerNames.clear()
	for userId in Network.userList:
		state.playerIds.append(userId.to_int())
		state.playerNames.append(Network.userList[userId])
	
	print('[MatchEventListener.gd] User list updated.')



func onUserLeftServer(id: int):
	Network.userList.erase(str(id))
	onNetwork_userListNeedsUpdate()

func startGame():
	print('[MatchEventListener.gd] Starting game.')
	state.currentPlayerIndex = 0
	setPlayerListForAll()
	setPlayButtonEnabled()
	rpc("initClients")

@rpc("call_remote", "reliable")
func initClients():
	print('[MatchEventListener.gd] Initializing clients.')
	state.currentPlayerIndex = 0
	setPlayerListForAll()
	setPlayButtonEnabled()

@rpc("any_peer", "call_local", "reliable")
func setPlayButtonEnabled():
	print('[MatchEventListener.gd] Setting button; current: ', state.currentPlayerIndex, ' my id: ', Network.userId)
	playButton.disabled = state.playerIds[state.currentPlayerIndex] != Network.userId
