extends Label

func _ready():
    var file = File.new()
    file.open("res://CREDITS.md", File.READ)
    text = file.get_as_text()
    file.close()

func _process(delta):
    rect_position.y -= 1

func _input(event):
    scene.change_scene("res://scenes/menu.tscn")
