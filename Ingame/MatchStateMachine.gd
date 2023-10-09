extends Node
class_name MatchStateMachine

var currentPlayerIndex = -1

var playerIds: Array[int]
var playerNames: Array[String]
var playerCards: Array[Array]
var finishedPlayers: Array[int]

signal playerIndexIncremented

func incrementPlayerIndex():
	currentPlayerIndex = (currentPlayerIndex + 1) % playerIds.size()
	while playerCards[currentPlayerIndex].size() == 0:
		currentPlayerIndex = (currentPlayerIndex + 1) % playerIds.size()
	playerIndexIncremented.emit()

func eraseCard(playerIndex: int, card: String):
	playerCards[playerIndex].erase(card)
	if playerCards[playerIndex].size() == 0:
		finishedPlayers.append(playerIndex)