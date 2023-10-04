extends Control
class_name OnlineMenu

@onready var username: LineEdit = %Username
@onready var ipAddress: LineEdit = %IpAddress
@onready var colorOptions: OptionButton = %ColorOptions
@onready var joinButton: Button = %JoinButton
@onready var hostButton: Button = %HostButton
@onready var statusLabel: Label = %StatusLabel

func _ready():
	prepareColorOptions()
	connectSignals()

func prepareColorOptions():
	colorOptions.clear()
	colorOptions.add_item("Red")
	colorOptions.add_item("Blue")
	colorOptions.add_item("Green")
	colorOptions.add_item("Yellow")
	colorOptions.add_item("Purple")
	colorOptions.add_item("Orange")
	colorOptions.add_item("Pink")

	colorOptions.select(0)
	onColorOptions_itemSelected(0)

func connectSignals():
	colorOptions.item_selected.connect(onColorOptions_itemSelected)
	joinButton.pressed.connect(onJoinButton_pressed)
	hostButton.pressed.connect(onHostButton_pressed)

	get_tree().get_multiplayer().connection_failed.connect(onConnectionFailed)

func onColorOptions_itemSelected(_index: int):
	Network.userColor = colorOptions.text

func onJoinButton_pressed():
	var client := ENetMultiplayerPeer.new()
	client.create_client(ipAddress.text, Network.PORT)
	# TODO: this sets global client
	# I could get local client, and so hosting and connecting would be decoupled
	# I could get hosting and connecting on the same screen
	# this would unify the code, and not make duplicate code at server and client
	# see: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#initializing-the-network
	get_tree().get_multiplayer().multiplayer_peer = client

	joinButton.disabled = true
	hostButton.disabled = true

	statusLabel.text = "STATUS: Connecting to server - " + ipAddress.text
	Network.username = username.text
	Network.userId = get_tree().get_multiplayer().get_unique_id()



func onHostButton_pressed():
	Network.hostServer()
	statusLabel.text = "STATUS: Hosting server"
	Network.username = username.text

	var id = get_tree().get_multiplayer().get_unique_id()
	Network.userId = id
	Network.userList[str(id)] = Network.username

func onConnectionFailed():
	print("[OnlineMenu.gd] Connection failed")
	statusLabel.text = "STATUS: Connection failed"

	joinButton.disabled = false
	hostButton.disabled = false