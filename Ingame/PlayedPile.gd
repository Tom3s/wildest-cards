extends Node2D
class_name PlayedPile

var cards = []

signal topCardChanged(card: String)

func playCard(card: String) -> bool:
	var topCard = cards.back()

	if topCard == null || playable(card, topCard):
		cards.append(card)
		topCardChanged.emit(card)
		return true
	else:
		return false

func playable(card: String, topCard: String = "") -> bool:
	if topCard == "":
		topCard = cards.back()
	var cardProperties = card.split("/")
	var topCardProperties = topCard.split("/")

	# match color
	if cardProperties[0] == topCardProperties[0] || cardProperties[0] == 'wild' || topCardProperties[0] == 'wild':
		return true
	# match number
	elif cardProperties[1] == topCardProperties[1]:
		return true
	return false

func getAndClearPlayedCards() -> Array[String]:
	var playedCards = cards
	cards = []
	return playedCards

func reset():
	cards = []
