extends Control



func _on_Label_meta_clicked(meta):
	OS.shell_open("https://deepdivegamestudio.itch.io")


func _on_Label2_meta_clicked(meta):
	var string = meta.split(":")[0]
	if string == "name":
		OS.shell_open("https://crusenho.itch.io")
	if string == "license":
		OS.shell_open("https://creativecommons.org/licenses/by/4.0/")


func _on_Label3_meta_clicked(meta):
	OS.shell_open("https://schwarnhild.itch.io")


func _on_Label4_meta_clicked(meta):
	OS.shell_open("https://jaofazjogos.itch.io/")
	


func _on_Label5_meta_clicked(meta):
	var string = meta.split(":")[0]
	if string == "name":
		OS.shell_open("https://piiixl.itch.io")
	if string == "license":
		OS.shell_open("https://creativecommons.org/licenses/by-nd/4.0/deed.en")


func _on_Label6_meta_clicked(meta):
	OS.shell_open("https://www.fontspace.com/deedeetype")


func _on_Label7_meta_clicked(meta):
	var string = meta.split(":")[0]
	if string == "name":
		OS.shell_open("https://freesound.org/people/RHumphries/")
	if string == "license":
		OS.shell_open("https://creativecommons.org/licenses/by/4.0/")


func _on_Label8_meta_clicked(meta):
	OS.shell_open("https://frosty-rabbid.itch.io/")


func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open("https://quokt.itch.io/")
