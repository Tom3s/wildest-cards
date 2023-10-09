extends Node
class_name MatchEventListener

@onready var startButton: Button = %StartButton
@onready var topCard: Label = %TopCard
@onready var drawButton: Button = %DrawButton
@onready var playerList: RichTextLabel = %PlayerList

@onready var state: MatchStateMachine = %MatchStateMachine

@onready var drawPile: DrawPile = %DrawPile
@onready var playedPile: PlayedPile = %PlayedPile
@onready var hand: ItemList = %Hand

const STARTING_CARDS = 7

func setup():
	drawButton.disabled = true
	startButton.disabled = Network.userId != 1
	connectSignals()

func connectSignals():
	startButton.pressed.connect(startGame)
	drawButton.pressed.connect(onDrawButton_pressed)

	hand.item_activated.connect(onHand_itemActivated)

	playedPile.topCardChanged.connect(onPlayedPile_topCardChanged)

	drawPile.outOfCards.connect(onDrawPile_outOfCards)

	Network.userListNeedsUpdate.connect(onNetwork_userListNeedsUpdate)
	get_tree().get_multiplayer().peer_disconnected.connect(onUserLeftServer)

func onDrawButton_pressed():
	rpc("drawCard", state.currentPlayerIndex)

@rpc("any_peer", "call_local", "reliable")
func drawCard(playerIndex: int):
	var card := (await drawPile.drawCards())[0]
	state.playerCards[playerIndex].append(card)
	state.playerCards[playerIndex].sort()
	if state.playerIds[playerIndex] == Network.userId:
		hand.add_item(card)
		hand.sort_items_by_text()
	incrementPlayerIndexForAll()


@rpc("any_peer", "call_local", "reliable")
func incrementPlayerIndexForAll():
	state.incrementPlayerIndex()
	setPlayerListForAll()
	setDrawButtonEnabled()
	setHandCardsEnabled()

@rpc("any_peer", "call_local", "reliable")
func setPlayerListForAll() -> void:
	playerList.setPlayers(state.playerNames, state.currentPlayerIndex, state.finishedPlayers)

func onHand_itemActivated(index: int):
	if state.playerIds[state.currentPlayerIndex] != Network.userId:
		return
	var card := hand.get_item_text(index)
	rpc("playCard", state.currentPlayerIndex, card, index)

func onPlayedPile_topCardChanged(card: String):
	topCard.text = card

func onDrawPile_outOfCards():
	if state.currentPlayerIndex != 0:
		return
	
	var cards := playedPile.getAndClearPlayedCards()
	drawPile.reshuffle(cards)

	var jsonCards := JSON.stringify(cards)
	rpc("setReshuffledPile", jsonCards)

@rpc("any_peer", "call_remote", "reliable")
func setReshuffledPile(jsonCards: String):
	var cards: Array[String] # = JSON.parse_string(jsonCards)
	cards.assign(JSON.parse_string(jsonCards))
	drawPile.setPile(cards)

@rpc("any_peer", "call_local", "reliable")
func playCard(playerIndex: int, card: String, cardIndex: int):
	if playedPile.playCard(card):
		# state.playerCards[playerIndex].erase(card)
		state.eraseCard(playerIndex, card)
		if state.playerIds[playerIndex] == Network.userId:
			hand.remove_item(cardIndex)
		incrementPlayerIndexForAll()
		# topCard.text = card

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
	# setDrawButtonEnabled()
	var initDeck := drawPile.reset()
	var jsonInitDeck := JSON.stringify(initDeck)
	rpc("initClients", jsonInitDeck)

@rpc("call_local", "reliable")
func initClients(jsonInitDeck: String):
	print('[MatchEventListener.gd] Initializing clients.')
	state.currentPlayerIndex = 0
	setPlayerListForAll()
	setDrawButtonEnabled()
	var initDeck: Array[String] # = JSON.parse_string(jsonInitDeck)
	initDeck.assign(JSON.parse_string(jsonInitDeck))
	drawPile.setPile(initDeck)

	playedPile.reset()
	playedPile.playCard((await drawPile.drawCards())[0])

	for i in range(state.playerIds.size()):
		state.playerCards[i].append_array(await drawPile.drawCards(STARTING_CARDS) as Array[String])
		state.playerCards[i].sort()
		if state.playerIds[i] == Network.userId:
			hand.clear()
			for card in state.playerCards[i]:
				hand.add_item(card)
	setHandCardsEnabled()
	
	

@rpc("any_peer", "call_local", "reliable")
func setDrawButtonEnabled():
	print('[MatchEventListener.gd] Setting button; current: ', state.currentPlayerIndex, ' my id: ', Network.userId)
	drawButton.disabled = state.playerIds[state.currentPlayerIndex] != Network.userId

@rpc("any_peer", "call_local", "reliable")
func drawCards(cards: Array[String]):
	print('[MatchEventListener.gd] Drawing cards: ', cards)
	state.drawCards(cards)
	setPlayerListForAll()
	setDrawButtonEnabled()

func setHandCardsEnabled():
	for i in range(hand.get_item_count()):
		hand.set_item_disabled(i, \
			state.playerIds[state.currentPlayerIndex] != Network.userId || \
			!playedPile.playable(hand.get_item_text(i)))
		# hand.set_item_selectable(i, playedPile.playable(hand.get_item_text(i)))

		
