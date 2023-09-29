extends Node

const PORT = 8765
const MAX_PLAYERS = 32

signal userListNeedsUpdate()

var username: String = "Chatter"
var userColor: String = "Red"

var userList: Dictionary = {}

func _ready():
	get_tree().get_multiplayer().connected_to_server.connect(onConnectedToServer)
	get_tree().get_multiplayer().server_disconnected.connect(onServerDisconnected)

func onConnectedToServer():
	print("[Network.gd] Connected to server")
	var id = get_tree().get_multiplayer().get_unique_id()
	var clientData = [str(id), username]
	rpc_id(1, "setUserData", clientData)
	changeToChatroom()

@rpc("any_peer", "call_local", "unreliable")
func setUserData(data):
	userList[str(data[0])] = data[1]
	userListNeedsUpdate.emit()
	rpc("updateUserList", userList)

@rpc("any_peer", "call_local", "unreliable")
func updateUserList(updatedUserList):
	userList = updatedUserList
	userListNeedsUpdate.emit()

func onServerDisconnected():
	print("[Network.gd] Server closed connection")
	OS.alert("Server closed connection", "Error")
	changeToOnlineMenu()

func hostServer():
	var server := ENetMultiplayerPeer.new()
	server.create_server(PORT, MAX_PLAYERS)

	get_tree().get_multiplayer().multiplayer_peer = server

	# to close:
	# .multiplayer_peer = null

	changeToChatroom()

func changeToChatroom():
	get_tree().change_scene_to_file("res://Chatroom.tscn")

func closeConnection():
	get_tree().get_multiplayer().multiplayer_peer = null
	userList.clear()
	changeToOnlineMenu()

func changeToOnlineMenu():
	get_tree().change_scene_to_file("res://OnlineMenu.tscn")
