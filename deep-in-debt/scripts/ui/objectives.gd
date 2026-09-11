extends VBoxContainer

@onready var objective_1: Label = $NinePatchRect2/Objective1
@onready var objective_2: Label = $NinePatchRect3/Objective2
@onready var objective_3: Label = $NinePatchRect4/Objective3

var current = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if current != Globals.get_garbage_count():
		current = Globals.get_garbage_count()
		objective_1.text = " Clean the town (" + str(Globals.max_garbage - current) + "/" + str(Globals.max_garbage) + ")"
	if objective_2.text != " Prepare party items (" + str(Globals.objective_2_counter) + "/4":
		objective_2.text = " Prepare party items (" + str(Globals.objective_2_counter) + "/4)"
	if Globals.objective_3:
		if objective_3.text != "Buy surprise cake (1/1)":
			objective_3.text = "Buy surprise cake (1/1)"
	else:
		if objective_3.text != "Buy surprise cake (0/1)":
			objective_3.text = "Buy surprise cake (0/1)"
