extends Node2D
class_name DrawPile

var cards = []

signal outOfCards
signal reshuffled

func reset():
	cards = CardFactory.getNewDeck()

func reshuffle(playedCards: Array[String]) -> void:
	cards = playedCards
	randomize()
	cards.shuffle()
	reshuffled.emit()


func drawCards(quantity: int = 1) -> Array[String]:
	if cards.size() < quantity:
		outOfCards.emit()
		await reshuffled
	
	var drawnCards = []
	for i in range(quantity):
		drawnCards.append(cards.pop_back())
	
	return drawnCards