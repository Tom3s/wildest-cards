extends RichTextLabel

func setPlayers(playerNames: Array[String], currentPlayerIndex: int, finishedPlayers: Array[int]) -> void:
	text = ""
	for i in range(playerNames.size()):
		if i == currentPlayerIndex:
			text += "[color=#00ff00]" + playerNames[i] + "[/color]"
		elif finishedPlayers.has(i):
			text += "[color=#0000aa]" + playerNames[i] + "[/color]"
		else:
			text += playerNames[i]
		text += "\n"