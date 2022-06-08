extends Control

### NODEPATHS ###
onready var nContainer_Margin := self.get_node("nContainer_Margin") as MarginContainer
onready var nContainer_Scroll := nContainer_Margin.get_node("nContainer_Scroll") as ScrollContainer
onready var nContainer_VBox := nContainer_Scroll.get_node("nContainer_VBox") as VBoxContainer
onready var nContainer_HBox := nContainer_VBox.get_node("nContainer_HBox") as HBoxContainer
onready var nLineEdit_Numbers := nContainer_HBox.get_node("nLineEdit_Numbers") as LineEdit
onready var nLineEdit_Cents := nContainer_HBox.get_node("nLineEdit_Cents") as LineEdit
onready var nOptionButton_Currency := nContainer_HBox.get_node("nOptionButton_Currency") as OptionButton
onready var nLabel_Letters := nContainer_VBox.get_node("nLabel_Letters") as Label

### LOCAL DATA ###
var nRegEx: RegEx = RegEx.new()
var bValid: bool = false
var sCurrencyMode: String = ""
var sNumberName: PoolStringArray = ["", ""]
var sCentsName: PoolStringArray = ["", ""]

### LOCAL INIT ###
func _ready() -> void:
	# Conections
	nLineEdit_Numbers.connect("text_changed", self, "nLineEdit_Numbers__text_changed")
	nLineEdit_Cents.connect("text_changed", self, "nLineEdit_Numbers__text_changed")
	nOptionButton_Currency.connect("item_selected", self, "nOptionButton_Currency__item_selected")
	# Default values
	nLineEdit_Cents.max_length = 3
	nLineEdit_Numbers.max_length = 15
	# Default calls
	nRegEx.compile("^[1-9][0-9]*$")
	nOptionButton_Currency.emit_signal("item_selected", 0)
	nLineEdit_Numbers.grab_focus()

### LOCAL METHODS ###
func nLineEdit_Numbers__text_changed(_origin: String) -> void:
	var _text: String = nLineEdit_Numbers.text
	bValid = false
	if nRegEx.search(_text.replace(".", "")):
		nLabel_Letters.text = Convert_Number(_text)
		if not nLabel_Letters.text.empty():
			var _split: PoolStringArray = nLabel_Letters.text.split(" ")
			if _split.size() > 0:
				nLabel_Letters.text += " " + sNumberName[0] if ("un" in _split and not "milion" in _split) else " " + sNumberName[1]
		nLabel_Letters.text = nLabel_Letters.text.replace("  ", " ")
		bValid = true
	else: nLabel_Letters.text = "Număr invalid"
	# Add thousand dot
	nLineEdit_Numbers.text = nLineEdit_Numbers.text.replace(".", "")
	if nLineEdit_Numbers.text.length() >= 4: nLineEdit_Numbers.text = nLineEdit_Numbers.text.insert(nLineEdit_Numbers.text.length() - 3, ".")
	if nLineEdit_Numbers.text.length() >= 8: nLineEdit_Numbers.text = nLineEdit_Numbers.text.insert(nLineEdit_Numbers.text.length() - 7, ".")
	if nLineEdit_Numbers.text.length() >= 12: nLineEdit_Numbers.text = nLineEdit_Numbers.text.insert(nLineEdit_Numbers.text.length() - 11, ".")
	nLineEdit_Numbers.caret_position = nLineEdit_Numbers.text.length()
	# Cents appending
	if bValid:
		var _suffix: String = " și "
		var _prefix: String = " " + sCentsName[0] + " " if nLineEdit_Cents.text == "1" else " " + sCentsName[1]
		if nRegEx.search(nLineEdit_Cents.text.replace(_suffix, "").replace(_prefix, "")):
			nLabel_Letters.text += _suffix + Convert_Number(nLineEdit_Cents.text) + _prefix

func Convert_Number(_source: String) -> String:
	var _result: String = ""
	var _text: String = _source.replace(".", "")
	var _length: int = _text.length()
	match _length:
		1: _result = Convert_Single_Digit(_text)
		2:
			if _text in ["11", "12", "13", "14", "15", "16", "17", "18", "19"]:
				_result = Convert_Constant_Digit(_text)
			else:
				if _text[1] == "0": _result = Convert_Double_Digit(_text)
				else:
					_result = Convert_Double_Digit(_text[0] + "0") + (
						"" if _text[0] == "0" else " și ") + ("unu" if _text[1] == "1" else Convert_Single_Digit(_text[1]))
		3:
			if _text[0] == "1": _result = "o sută "
			elif _text[0] == "2": _result = "două sute "
			else: _result = Convert_Single_Digit(_text[0]) + " sute "
			if not (_text[1] == "0" and _text[2] == "0"):
				if _text[1] == "0" and _text[2] == "1": _result += " unu"
				else: _result += Convert_Number(("" if _text[1] == "0" else _text[1]) + _text[2])
		4, 5, 6:
			match _length:
				4:
					if _text[0] == "1": _result = "o mie "
					else: _result = (Convert_Single_Digit(_text[0]) + " mii ").replace("doi", "două")
				5: _result = (Convert_Number(_text[0] + _text[1]) + " mii ").replace("doi", "două")
				6: _result = (Convert_Number(_text[0] + _text[1] + _text[2]) + " mii ").replace("doi", "două")
			var _k1: int = _length - 3
			var _k2: int = _length - 2
			var _k3: int = _length - 1
			if not (_text[_k1] == "0" and _text[_k2] == "0" and _text[_k3] == "0"):
				if _text[_k1] == "0" and _text[_k2] == "0" and _text[_k3] == "1": _result += " unu"
				else: _result += Convert_Number(("" if _text[_k1] == "0" else _text[_k1]) + _text[_k2] + _text[_k3])
		7, 8, 9:
			match _length:
				7:
					if _text[0] == "1": _result = "un milion "
					else: _result = (Convert_Single_Digit(_text[0]) + " milioane ").replace("doi", "două")
				8: _result = (Convert_Number(_text[0] + _text[1]) + " milioane ").replace("doi", "două")
				9: _result = (Convert_Number(_text[0] + _text[1] + _text[2]) + " milioane ").replace("doi", "două")
			var _k1: int = _length - 3 ; var _m1: int = _length - 6
			var _k2: int = _length - 2 ; var _m2: int = _length - 5
			var _k3: int = _length - 1 ; var _m3: int = _length - 4
			if not (_text[_m1] == "0" and _text[_m2] == "0" and _text[_m3] == "0"):
				if _text[_m1] == "0" and _text[_m2] == "0" and _text[_m3] == "1": _result += " unu mii "
				else: _result += (Convert_Number(("" if _text[_m1] == "0" else _text[_m1]) + _text[_m2] + _text[_m3]) + " mii ").replace("doi", "două")
			if not (_text[_k1] == "0" and _text[_k2] == "0" and _text[_k3] == "0"):
				if _text[_k1] == "0" and _text[_k2] == "0" and _text[_k3] == "1": _result += " unu"
				else: _result += Convert_Number(("" if _text[_k1] == "0" else _text[_k1]) + _text[_k2] + _text[_k3])
		10, 11, 12:
			match _length:
				10:
					if _text[0] == "1": _result = "un miliard "
					else: _result = (Convert_Single_Digit(_text[0]) + " miliarde ").replace("doi", "două")
				11: _result = (Convert_Number(_text[0] + _text[1]) + " miliarde ").replace("doi", "două")
				12: _result = (Convert_Number(_text[0] + _text[1] + _text[2]) + " miliarde ").replace("doi", "două")
			var _k1: int = _length - 3 ; var _m1: int = _length - 6 ; var _b1: int = _length - 9
			var _k2: int = _length - 2 ; var _m2: int = _length - 5 ; var _b2: int = _length - 8
			var _k3: int = _length - 1 ; var _m3: int = _length - 4 ; var _b3: int = _length - 7
			if not (_text[_b1] == "0" and _text[_b2] == "0" and _text[_b3] == "0"):
				if _text[_b1] == "0" and _text[_b2] == "0" and _text[_b3] == "1": _result += " unu milioane "
				else: _result += (Convert_Number(("" if _text[_b1] == "0" else _text[_b1]) + _text[_b2] + _text[_b3]) + " milioane ").replace("doi", "două")
			if not (_text[_m1] == "0" and _text[_m2] == "0" and _text[_m3] == "0"):
				if _text[_m1] == "0" and _text[_m2] == "0" and _text[_m3] == "1": _result += " unu mii "
				else: _result += (Convert_Number(("" if _text[_m1] == "0" else _text[_m1]) + _text[_m2] + _text[_m3]) + " mii ").replace("doi", "două")
			if not (_text[_k1] == "0" and _text[_k2] == "0" and _text[_k3] == "0"):
				if _text[_k1] == "0" and _text[_k2] == "0" and _text[_k3] == "1": _result += " unu"
				else: _result += Convert_Number(("" if _text[_k1] == "0" else _text[_k1]) + _text[_k2] + _text[_k3])
	return _result

func Convert_Single_Digit(_number: String) -> String:
	match _number:
		"0": return "zero"
		"1": return "un"
		"2": return "doi"
		"3": return "trei"
		"4": return "patru"
		"5": return "cinci"
		"6": return "șase"
		"7": return "șapte"
		"8": return "opt"
		"9": return "nouă"
		_: return ""

func Convert_Double_Digit(_number: String) -> String:
	match _number:
		"10": return "zece"
		"20": return "douăzeci"
		"30": return "treizeci"
		"40": return "patruzeci"
		"50": return "cincizeci"
		"60": return "șaizeci"
		"70": return "șaptezeci"
		"80": return "optzeci"
		"90": return "nouăzeci"
		_: return ""

func Convert_Constant_Digit(_number: String) -> String:
	match _number:
		"11": return "unsprezece"
		"12": return "doisprezece"
		"13": return "treisprezece"
		"14": return "paisprezece"
		"15": return "cincisprezece"
		"16": return "șaisprezece"
		"17": return "șaptesprezece"
		"18": return "optsprezece"
		"19": return "nouăsprezece"
		_: return ""

func nOptionButton_Currency__item_selected(_id: int) -> void:
	sCurrencyMode = nOptionButton_Currency.get_item_text(_id)
	match sCurrencyMode:
		"RON":
			nLineEdit_Numbers.placeholder_text = "Leu românesc"
			nLineEdit_Cents.placeholder_text = "Bani"
			sNumberName = ["leu", "lei"]
			sCentsName = ["ban", "bani"]
		"EUR":
			nLineEdit_Numbers.placeholder_text = "Euro"
			nLineEdit_Cents.placeholder_text = "Cenți"
			sNumberName = ["euro", "euro"]
			sCentsName = ["cent", "cenți"]
	nLineEdit_Numbers__text_changed(nLineEdit_Numbers.text)
