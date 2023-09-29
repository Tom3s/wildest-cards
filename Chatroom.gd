extends Control
class_name Chatroom


@onready var chatHistory: RichTextLabel = %ChatHistory
@onready var userList: ItemList = %UserList
@onready var textMessage: LineEdit = %TextMessage
@onready var sendButton: Button = %SendButton
@onready var exitButton: Button = %ExitButton

func _ready():
	connectSignals()

	if (get_tree().get_multiplayer().get_unique_id() == 1):
		onNetwork_userListNeedsUpdate()
	
	rpc("recordChatMessage", "[b][color=" + Network.userColor.to_lower() + "]" + Network.username + "[/color][/b] joined the server\n") 

func connectSignals():
	sendButton.pressed.connect(onSendButton_pressed)
	exitButton.pressed.connect(onExitButton_pressed)

	textMessage.text_submitted.connect(onTextMessage_textSubmitted)

	Network.userListNeedsUpdate.connect(onNetwork_userListNeedsUpdate)
	get_tree().get_multiplayer().peer_disconnected.connect(onUserLeftServer)

func onSendButton_pressed():
	var rawMessage = textMessage.text
	if (rawMessage != "" and rawMessage != "\n"):
		rpc("recordChatMessage", getFormattedMessage())
		# chatHistory.text += getFormattedMessage()
	textMessage.text = ""

@rpc("any_peer", "call_local", "unreliable")
func recordChatMessage(message: String):
	chatHistory.text += message
	chatHistory.scroll_to_line(chatHistory.get_line_count())

func getFormattedMessage():
	return "[b][color=" + Network.userColor.to_lower() + "]" + Network.username + "[/color][/b]: " + textMessage.text + ("" if (textMessage.text.ends_with("\n")) else "\n")

func onExitButton_pressed():
	Network.closeConnection()

func onTextMessage_textSubmitted(_newText: String):
	onSendButton_pressed()

func onNetwork_userListNeedsUpdate():
	userList.clear()
	for userId in Network.userList:
		userList.add_item(Network.userList[userId])

func onUserLeftServer(id: int):
	print("[Chatroom.gd] User with id", id, "left the server")
	# rpc("recordChatMessage", "[b][color=" + Network.userColor.to_lower() + "]" + Network.username + "[/color][/b] left the server\n") 
	recordChatMessage("[b][i][color=#cccccc]" + Network.userList[str(id)] + " left the server[/color][/i][/b]\n") 
	Network.userList.erase(str(id))
	onNetwork_userListNeedsUpdate()



