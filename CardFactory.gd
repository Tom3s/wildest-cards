extends Node
class_name CardFactory

const COLORS = [
	'red',
	'blue',
	'green',
	'yellow',
]

const MIN_VALUE = 0
const MAX_VALUE = 10

const COLORED_SPECIALS = [
	'drawTwo',
	'reverse',
	'skip',
]

const WILD_SPECIALS = [
	'basic',
	'drawFour',
]

static func getNewDeck() -> Array[String]:
	var deck: Array[String] = []
	for color in COLORS:
		for value in range(MIN_VALUE, MAX_VALUE + 1):
			deck.append(color + '/' + str(value))
		for special in COLORED_SPECIALS:
			deck.append(color + '/' + special)
			deck.append(color + '/' + special)
	for special in WILD_SPECIALS:
		deck.append('wild/' + special)
		deck.append('wild/' + special)
		deck.append('wild/' + special)

	# this ensures that the deck is always shuffled differently
	randomize()
	deck.shuffle()

	return deck
