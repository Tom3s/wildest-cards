extends Node2D
class_name DrawPile

var cards = []

signal outOfCards
signal reshuffled

func reset() -> Array[String]:
	cards = CardFactory.getNewDeck()
	return cards

func reshuffle(playedCards: Array[String]) -> void:
	cards = playedCards
	randomize()
	cards.shuffle()
	reshuffled.emit()


func drawCards(quantity: int = 1) -> Array[String]:
	if cards.size() < quantity:
		outOfCards.emit()
		await reshuffled
	
	var drawnCards: Array[String] = []
	for i in range(quantity):
		drawnCards.append(cards.pop_back())
	
	return drawnCards

func setPile(initCards: Array[String]) -> void:
	cards = initCards
