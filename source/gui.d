import std.conv: text, to;

import dlangui;

import jmisc;

import control, taskman;

struct Gui {
private:
	Window _window;
	EditBox _editBoxMain;
	TextWidget _textWidgetCategory;
	EditLine _editLineId,
		_editLineAddCat,
		_editLineComment,
		_editLineDate,
		_editLineTime,
		_editLineEndTime,
		_editLineDuration;
	CheckBox _checkBoxTime,
			_checkBoxEndTime,
			_checkBoxAddCat;

    TaskMan _taskMan;
    Control _control;

    string _input;
public:
    auto getInput() {
        return _input;
    }

	int setup(ref TaskMan taskMan) {
        _taskMan = taskMan;
        _control.setup(_taskMan);

		_window = Platform.instance.createWindow(
			"Time Log", null, WindowFlag.Resizable, 1280, 800);

		// Crease widget to show in window
		_window.mainWidget = parseML(q{
			HorizontalLayout {
				//#0000FF #C0E0E070
				backgroundColor: "#7070FF0C" // Lime green
				HorizontalLayout {
					VerticalLayout {
						margins: 3
						padding: 3

						EditBox {
							id: editBoxMain
							minWidth: 1100; minHeight: 700; maxHeight: 640;
						}

						Button { id: buttonActivate; maxWidth: 100; text: "- Activate Last Line -" }

						HorizontalLayout {
							TextWidget { text: "Category:" }
							TextWidget {
								id: textWidgetCategory
								text: "(none set)"
							}
						}

						HorizontalLayout {
							TextWidget { text: "Comment:" }
							EditLine {
								id: editLineComment
								minWidth: 900; maxWidth: 900
								text: ""
							}

							Button { id: buttonTest; text: "Command"; }
						}
					}
					VerticalLayout {
						HorizontalLayout {
							TextWidget { text: "Ref:" }
							EditLine { id: editLineId; text: "0"; minWidth: 100; maxWidth: 100 }
						}

						Button { id: buttonGet; maxWidth: 100; text: "Get" }

						TextWidget { text: "Add categories:" }
						HorizontalLayout { EditLine { id: editLineAddCat; text: ""; minWidth: 100; maxWidth: 100 } CheckBox { id: checkBoxAddCat; } }

						TextWidget { text: "Date:" }
						EditLine { id: editLineDate; text: "1 1 2018"; minWidth: 100; maxWidth: 100 }
						TextWidget { text: "Time:" }
						HorizontalLayout { EditLine { id: editLineTime; text: "0 0 0"; minWidth: 100; maxWidth: 100 } CheckBox { id: checkBoxTime; } }
						TextWidget { text: "End Time:" }
						HorizontalLayout { EditLine { id: editLineEndTime; text: "0 0 0"; minWidth: 100; maxWidth: 100 } CheckBox { id: checkBoxEndTime; } }
						TextWidget { text: "Duration:" }
						EditLine { id: editLineDuration; text: "0 0 0"; minWidth: 100; maxWidth: 100 }
						
						Button { id: buttonSet; maxWidth: 100; text: "Set" }

					}
				}
			}
		});

		_editBoxMain = _window.mainWidget.childById!EditBox("editBoxMain");
		_editLineId = _window.mainWidget.childById!EditLine("editLineId");
		_editLineAddCat = _window.mainWidget.childById!EditLine("editLineAddCat");
		_textWidgetCategory = _window.mainWidget.childById!TextWidget("textWidgetCategory");
		_editLineDate = _window.mainWidget.childById!EditLine("editLineDate");
		_editLineTime = _window.mainWidget.childById!EditLine("editLineTime");
		_editLineEndTime = _window.mainWidget.childById!EditLine("editLineEndTime");
		_editLineDuration = _window.mainWidget.childById!EditLine("editLineDuration");
		_editLineComment = _window.mainWidget.childById!EditLine("editLineComment");
		_checkBoxTime = _window.mainWidget.childById!CheckBox("checkBoxTime");
		_checkBoxEndTime = _window.mainWidget.childById!CheckBox("checkBoxEndTime");
		_checkBoxAddCat = _window.mainWidget.childById!CheckBox("checkBoxAddCat");
		
//<<<<<<< HEAD
//<<<<<<< HEAD
		_window.mainWidget.childById!Button("buttonTest").click = delegate(Widget w) {
			EditLine _editLineSpot;
			
			Window _spotWin;
			
			_spotWin = Platform.instance.createWindow(
				"Command", null, WindowFlag.Resizable, 800, 50);

			_spotWin.mainWidget = parseML(q{
				HorizontalLayout {
					backgroundColor: "#C0E0E070" // semitransparent yellow background
					HorizontalLayout {
						TextWidget {
							text: "Enter command:"
						}
						EditLine {
							id: editLineSpot
							minWidth: 500
						}
						Button {
							id: buttonAction
							text: "Action"
						}
					}
				}
			});

			_editLineSpot = _spotWin.mainWidget.childById!EditLine("editLineSpot");

			_spotWin.mainWidget.childById!Button("buttonAction").click = delegate(Widget w) {
				auto output = _control.processInput(_editLineSpot.text.to!string);

				if (output.length > 0) {
					_editBoxMain.text = _editBoxMain.text ~ (output ~ "\n").to!dstring;
//=======
//=======
//>>>>>>> parent of 489dc14... Failed proper dialog box
		import std.datetime: DateTime, Clock;
//>>>>>>> parent of 489dc14... Failed proper dialog box

					return true;
				}

				return false;
			};

			return true;
		};

//<<<<<<< HEAD
//=======
		_window.mainWidget.childById!Button("buttonTest").click = delegate(Widget w) {
			EditLine _editLineSpot;
			
			Window _spotWin;
			
			_spotWin = Platform.instance.createWindow(
				"Command", null, WindowFlag.Resizable, 800, 50);

			_spotWin.mainWidget = parseML(q{
				HorizontalLayout {
					backgroundColor: "#C0E0E070" // semitransparent yellow background
					HorizontalLayout {
						TextWidget {
							text: "Enter command:"
						}
						EditLine {
							id: editLineSpot
							minWidth: 500
						}
						Button {
							id: buttonAction
							text: "Action"
						}
					}
				}
			});

			_editLineSpot = _spotWin.mainWidget.childById!EditLine("editLineSpot");

			_spotWin.mainWidget.childById!Button("buttonAction").click = delegate(Widget w) {
				auto output = _control.processInput(_editLineSpot.text.to!string);

				if (output.length > 0) {
					_editBoxMain.text = _editBoxMain.text ~ (output ~ "\n").to!dstring;

					return true;
				}

				return false;
			};

/+
<<<<<<< HEAD
>>>>>>> parent of 489dc14... Failed proper dialog box
=======
>>>>>>> parent of 489dc14... Failed proper dialog box
+/
			_spotWin.show();

			return true;
		};

		_window.mainWidget.childById!Button("buttonActivate").click = delegate(Widget w) {
			import std.string: lastIndexOf;
			import std.conv: to;

            auto i = _editBoxMain.text.to!string.lastIndexOf("\n") + 1;
            _input = _editBoxMain.text[i .. $].to!string;
            (`"` ~ _input ~ `"`).gh;
            auto output = _control.processInput(_input);
            if (output.length > 0)
                _editBoxMain.text = _editBoxMain.text ~ (output ~ "\n").to!dstring;

            return true;
		};
		_window.mainWidget.childById!Button("buttonGet").click = delegate(Widget w) {

            int id;
			try {
				id = _editLineId.text.to!int;
			} catch(Exception e) {
				return false;
			}

			auto task = _taskMan.getTask(id); 
			if (task is null) {
				_editBoxMain.text = _editBoxMain.text ~ "\nTask out of range!";

				return false;
			} else {
				_textWidgetCategory.text = task.id().to!dstring ~ " " ~ task.taskString.to!dstring;

				_editLineDate.text = text(task.dateTime.day, " ", cast(int)task.dateTime.month, " ", task.dateTime.year).to!dstring;

				_checkBoxTime.checked = task.displayTimeFlag;
				if (_checkBoxTime.checked)
					_editLineTime.text = text(task.dateTime.hour, " ", task.dateTime.minute, " ", task.dateTime.second).to!dstring;
				else
					_editLineTime.text = ""d;

				_checkBoxEndTime.checked = task.displayEndTimeFlag;
				if (_checkBoxEndTime.checked)
					_editLineEndTime.text = text(task.endTime.hour, " ", task.endTime.minute, " ", task.endTime.second).to!dstring;
				else
					_editLineEndTime.text = ""d;
				
				if (task.timeLength.hours ==0 && task.timeLength.minutes == 0 && task.timeLength.seconds == 0)
					_editLineDuration.text = ""d;
				else
					_editLineDuration.text = text(task.timeLength.hours, " ", task.timeLength.minutes, " ", task.timeLength.seconds).to!dstring;

				_editLineComment.text = task.comment().to!dstring;
			}

            return true;
		};

		_window.mainWidget.childById!Button("buttonSet").click = delegate(Widget w) {
			import std.string: split, join, format;
			auto loadValues() {
				//             Set Date
				//             | Start time
				//             | | End time
				//             | | | length of time
				//             | | | | comment
				//             | | | | |  
				return format(`%s%s%s%sc"%s"`,
						text(`sd"`, _editLineDate.text, `" `),
						_checkBoxTime.checked ? text(`st"`, _editLineTime.text, `" `) : "",
						_checkBoxEndTime.checked ? text(`et"`, _editLineEndTime.text, `" `) : "",
						_editLineDuration.text.split.join(" ") != "0 0 0" ? text(`l"`, _editLineDuration.text, `" `) : "",
						_editLineComment.text).to!string;
			}

			if (_checkBoxAddCat.checked) {
				_editBoxMain.text = _editBoxMain.text ~ text("\n",
					_editLineAddCat.text.split.join(" "), " ",
					loadValues()).to!dstring;
			} else {
				int[] selection;
				try {
					selection = _editLineId.text.split.to!(int[]);
				} catch(Exception e) {
					_editBoxMain.text = _editBoxMain.text ~ "\nFailed!"d;

					return false;
				}

				_control.processInput(loadValues, selection);
				/+
				foreach(s; selection) {
					_control.processInput("s" ~ s.to!string);
					_control.processInput(loadValues, s);
					_editBoxMain.text = _editBoxMain.text ~ text("s", s, "\n", loadValues, "\n").to!dstring;
				}
				+/
			}

            return true;
		};

		_editBoxMain.text = "Insert 'h' at the bottom line,\n" ~
			"then press the Activate button for help\n".to!dstring;

		_window.show();

		return 0;
    }
}
