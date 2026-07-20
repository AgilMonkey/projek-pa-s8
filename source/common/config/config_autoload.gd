extends Node

# Server config
var server_ip: String = "127.0.0.1"
var server_port: int = 42069
var max_players: int = 100
var tick_rate: int = 60

# Client config
var fullscreen: bool = false
var volume: float = 1.0
var username: String = ""

func _ready():
	load_config()
	if OS.has_feature("production"):
		server_ip = "poliban-english-verse.duckdns.org"

func load_config():
	var config = ConfigFile.new()
	var err = config.load("config.cfg")
	if err != OK:
		save_config()  # create default config if none exists
		return
	
	server_ip = config.get_value("server", "ip", server_ip)
	server_port = config.get_value("server", "port", server_port)
	max_players = config.get_value("server", "max_players", max_players)
	
	fullscreen = config.get_value("client", "fullscreen", fullscreen)
	volume = config.get_value("client", "volume", volume)
	username = config.get_value("client", "username", username)

func save_config():
	var config = ConfigFile.new()
	
	config.set_value("server", "ip", server_ip)
	config.set_value("server", "port", server_port)
	config.set_value("server", "max_players", max_players)
	
	config.set_value("client", "fullscreen", fullscreen)
	config.set_value("client", "volume", volume)
	config.set_value("client", "username", username)
	
	if OS.has_feature("editor"): return
	config.save("config.cfg")
