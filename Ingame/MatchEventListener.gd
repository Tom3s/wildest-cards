extends Node
class_name MatchEventListener

@onready var startButton: Button = %StartButton
@onready var playButton: Button = %PlayButton
@onready var playerList: RichTextLabel = %PlayerList

@onready var state: MatchStateMachine = %MatchStateMachine

@onready var drawPile: DrawPile = %DrawPile
@onready var hand: ItemList = %Hand

const STARTING_CARDS = 7

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
	state.playerCards.clear()
	for userId in Network.userList:
		state.playerIds.append(userId.to_int())
		state.playerNames.append(Network.userList[userId])
		state.playerCards.append([] as Array[String])
	
	print('[MatchEventListener.gd] User list updated.')



func onUserLeftServer(id: int):
	Network.userList.erase(str(id))
	onNetwork_userListNeedsUpdate()

func startGame():
	print('[MatchEventListener.gd] Starting game.')
	# state.currentPlayerIndex = 0
	# setPlayerListForAll()
	# setPlayButtonEnabled()
	var initDeck := drawPile.reset()
	var jsonInitDeck := JSON.stringify(initDeck)
	rpc("initClients", jsonInitDeck)

@rpc("call_local", "reliable")
func initClients(jsonInitDeck: String):
	print('[MatchEventListener.gd] Initializing clients.')
	state.currentPlayerIndex = 0
	setPlayerListForAll()
	setPlayButtonEnabled()
	var initDeck: Array[String] # = JSON.parse_string(jsonInitDeck)
	initDeck.assign(JSON.parse_string(jsonInitDeck))
	drawPile.setPile(initDeck)

	for i in range(state.playerIds.size()):
		state.playerCards[i].append_array(await drawPile.drawCards(STARTING_CARDS) as Array[String])

		if state.playerIds[i] == Network.userId:
			hand.clear()
			for card in state.playerCards[i]:
				hand.add_item(card)

@rpc("any_peer", "call_local", "reliable")
func setPlayButtonEnabled():
	print('[MatchEventListener.gd] Setting button; current: ', state.currentPlayerIndex, ' my id: ', Network.userId)
	playButton.disabled = state.playerIds[state.currentPlayerIndex] != Network.userId

@rpc("any_peer", "call_local", "reliable")
func drawCards(cards: Array[String]):
	print('[MatchEventListener.gd] Drawing cards: ', cards)
	state.drawCards(cards)
	setPlayerListForAll()
	setPlayButtonEnabled()
