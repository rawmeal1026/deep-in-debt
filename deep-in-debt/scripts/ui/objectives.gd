extends VBoxContainer

@onready var objective_1: Label = $NinePatchRect2/Objective1
@onready var objective_2: Label = $NinePatchRect3/Objective2
@onready var objective_3: Label = $NinePatchRect4/Objective3

var current = 0

func _ready() -> void:
	Signals.garbage_collected.connect(decrease_current_garbage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if current != Globals.get_garbage_count():
		current = Globals.get_garbage_count()
		objective_1.text = " Clean the town (" + str(Globals.max_garbage - current) + "/" + str(Globals.max_garbage) + ")"
		if !Globals.objective_1:
			if current == 0:
				Globals.objective_1 = true
	if objective_2.text != " Prepare party items (" + str(Globals.objective_2_counter) + "/4":
		objective_2.text = " Prepare party items (" + str(Globals.objective_2_counter) + "/4)"
		if !Globals.objective_2:
			if Globals.objective_2_counter == 4:
				Globals.objective_2 = true
	if Globals.objective_3:
		if objective_3.text != "Buy surprise cake (1/1)":
			objective_3.text = "Buy surprise cake (1/1)"
			if !Globals.objective_3:
				Globals.objective_3 = true
	else:
		if objective_3.text != "Buy surprise cake (0/1)":
			objective_3.text = "Buy surprise cake (0/1)"

func decrease_current_garbage():
	Globals.current_garbage -= 1
	objective_1.text = " Clean the town (" + str(Globals.current_garbage) + "/" + str(Globals.max_garbage) + ")"
