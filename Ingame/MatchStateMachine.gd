extends Node
class_name MatchStateMachine

var currentPlayerIndex = -1

var playerIds: Array[int]
var playerNames: Array[String]
var playerCards: Array[Array]

signal playerIndexIncremented

func incrementPlayerIndex():
	currentPlayerIndex = (currentPlayerIndex + 1) % playerIds.size()
	playerIndexIncremented.emit()
