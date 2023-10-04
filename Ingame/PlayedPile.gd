extends Node2D
class_name PlayedPile

var cards = []

func playCard(card: String) -> bool:
	var topCard = cards[-1]

	if playable(card, topCard):
		cards.append(card)
		return true
	else:
		return false

func playable(card: String, topCard: String) -> bool:
	var cardProperties = card.split("/")
	var topCardProperties = topCard.split("/")

	# match color
	if cardProperties[0] == topCardProperties[0] || cardProperties[0] == 'wild':
		return true
	# match number
	elif cardProperties[1] == topCardProperties[1]:
		return true
	return false

func getAndClearPlayedCars() -> Array[String]:
	var playedCards = cards
	cards = []
	return playedCards
