//#need more work
//#comes up with unknown id in the terminal output
//#to be remembered
// multiple
import std.conv: text, to;
import std.traits: isSomeString;

import dlangui;

import jmisc;

import control, taskman;

struct Gui {
private:
	Window _window,
		_commandInputWindow;
	EditBox _editBoxMain,
		_editBoxHistory;
	TextWidget _textWidgetCategory;
	TextWidget _textWidgetStatus; //#to be remembered
	EditLine _editLineId,
		_editLineAddCat,
		_editLineComment,
		_editLineDate,
		_editLineTime,
		_editLineEndTime,
		_editLineDuration,
		_editLineCommand;
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
			"ChronoLog", null, WindowFlag.Resizable, 1280, 800);

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
							minWidth: 1100; minHeight: 460;
						}

						TextWidget { text: "History:" }
						EditBox {
							id: editBoxHistory
							minWidth: 1100; minHeight: 100;
						}

						HorizontalLayout {
							TextWidget { text: "Add categories:" }
							EditLine { id: editLineAddCat; text: ""; minWidth: 200; maxWidth: 200 }
							CheckBox { id: checkBoxAddCat; }

							TextWidget { text: "Get/Set Reference(s):" }
							EditLine { id: editLineId; text: "0"; minWidth: 400; maxWidth: 400 }

							Button { id: buttonWrap; text: "Wrap Text" }
						}

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
								minWidth: 900
								text: ""
							}
						}

						HorizontalLayout {
							TextWidget { text: "Command Input:" }
							EditLine {
								id: editLineCommand
								minWidth: 400
							}
							Button { id: buttonActivate; text: "Activate" }
						}

						HorizontalLayout {
							TextWidget { text: "Status:" }
							TextWidget { id: textWidgetStatus }
						}
					}
					VerticalLayout {
						Button { id: buttonGet; maxWidth: 100; text: "Get" }

						TextWidget { text: "Date:" }
						EditLine { id: editLineDate; text: "1 1 2018"; minWidth: 100; maxWidth: 100 }
						TextWidget { text: "Time:" }
						HorizontalLayout { EditLine { id: editLineTime; text: "0 0 0"; minWidth: 100; maxWidth: 100 } CheckBox { id: checkBoxTime; } }
						TextWidget { text: "End Time:" }
						HorizontalLayout { EditLine { id: editLineEndTime; text: "0 0 0"; minWidth: 100; maxWidth: 100 } CheckBox { id: checkBoxEndTime; } }
						TextWidget { text: "Duration:" }
						EditLine { id: editLineDuration; text: "0 0 0"; minWidth: 100; maxWidth: 100 }
						
						Button { id: buttonSet; maxWidth: 100; text: "Set" }
						TextWidget { text: "---" }
						Button { id: buttonProcess; text: "Process!"; }
						TextWidget { text: "---" }
						Button { id: buttonSave; text: "Save"; }
						Button { id: buttonYSave; text: "Yesterday Save"; }
						TextWidget { text: "---" }
						Button { id: buttonView; text: "View Categories"; }
						Button { id: buttonTime; text: "Time"; }
						Button { id: buttonHelp; text: "Help"; }
						TextWidget { text: "---" }
						Button { id: buttonClear; text: "Clear"; }
					}
				}
			}
		});

		_editBoxMain = _window.mainWidget.childById!EditBox("editBoxMain");
		_editBoxHistory = _window.mainWidget.childById!EditBox("editBoxHistory");
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
		_editLineCommand = _window.mainWidget.childById!EditLine("editLineCommand");
		_textWidgetStatus = _window.mainWidget.childById!TextWidget("textWidgetStatus");

		_window.mainWidget.childById!Button("buttonProcess").click = delegate(Widget w) {
			//#need more work
			string result = _control.processCommandsFromTextFileOrEditBox(_editBoxMain.text.to!string);

			addToHistory("Process button pressed..");
			_editBoxMain.text = _editBoxMain.text ~ "\n" ~ result.to!dstring;
			
			return true;
		};

		_window.mainWidget.childById!Button("buttonSave").click = delegate(Widget w) {
			return processInputAndAddToMain("save");
		};

		_window.mainWidget.childById!Button("buttonYSave").click = delegate(Widget w) {
			return processInputAndAddToMain(`save"yesterday"`);
		};

		_window.mainWidget.childById!Button("buttonView").click = delegate(Widget w) {
			return processInputAndAddToMain("viewCategories");
		};

		_window.mainWidget.childById!Button("buttonTime").click = delegate(Widget w) {
			return processInputAndAddToMain("time");
		};

		_window.mainWidget.childById!Button("buttonHelp").click = delegate(Widget w) {
			return processInputAndAddToMain("help");
		};

		_window.mainWidget.childById!Button("buttonClear").click = delegate(Widget w) {
			_editBoxMain.text = ""d;
			addToHistory("Main edit box cleared");

			return true;
		};

		_window.mainWidget.childById!Button("buttonActivate").click = delegate(Widget w) {
			return processInputAndAddToMain(_editLineCommand.text.to!string);
		};

		import std.datetime: DateTime, Clock;

		auto dt = cast(DateTime)Clock.currTime();
		_editLineDate.text = text(dt.day, ".", cast(int)dt.month, ".", dt.year).to!dstring;
		immutable time0 = text(dt.hour, ":", dt.minute, ":", dt.second).to!dstring;
		_editLineTime.text = time0;
		_editLineEndTime.text = time0;
		_editLineDuration.text = "0:0:0"d;

		_window.mainWidget.childById!Button("buttonWrap").click = delegate(Widget w) {
			import std.string: split, wrap;

			dstring s;
			auto paragraphs = _editBoxMain.text.split("\n");
			foreach(line; paragraphs)
				s ~= wrap(line, 116, null, null, 4);
			_editBoxMain.text = s;

			addToHistory("Text wrapped. (was ", paragraphs.length, " lines)");

			return true;
		};

version(none) {
	/+
		EditLine editLineSpot;

		_commandInputWindow = Platform.instance.createWindow(
				"Command", null, WindowFlag.Resizable, 800, 50);

		_commandInputWindow.mainWidget = parseML(q{
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

		editLineSpot = _commandInputWindow.mainWidget.childById!EditLine("editLineSpot");

		_commandInputWindow.mainWidget.childById!Button("buttonAction").click = delegate(Widget w) {
			return processInputAndAddToMain(editLineSpot.text.to!string);
		};

		_window.mainWidget.childById!Button("buttonTest").click = delegate(Widget w) {
			_commandInputWindow.show();

			return true;
		};
	+/
	} // version not work, comes up with a blank window

		_window.mainWidget.childById!Button("buttonGet").click = delegate(Widget w) {
			addToHistory("Get pressed for ", _editLineId.text);
            int id;
			try {
				id = _editLineId.text.to!int;
			} catch(Exception e) {
				_editBoxMain.text = _editBoxMain.text ~ "\nCouldn't read reference input, (maybe more than one number there).";

				return false;
			}

			auto task = _taskMan.getTask(id); 
			if (task is null) {
				immutable error = "Task # out of range! (0-"d ~ (_taskMan.numberOfTasks - 1).to!dstring ~ ")"d;

				_editBoxMain.text = _editBoxMain.text ~ "\n" ~ error;
				addToHistory(error);

				return false;
			} else {
				_textWidgetCategory.text = task.id().to!dstring ~ " - " ~ task.taskString.to!dstring;

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
// benefits
//  reason raisins
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
						_control.for3Nums(_editLineDuration.text.to!string) != "0 0 0" ? text(`l"`, _editLineDuration.text, `" `) : "",
						_editLineComment.text).to!string;
			}
			immutable ldvalues = loadValues;

			if (_checkBoxAddCat.checked) {
				immutable txt = text(_editLineAddCat.text.split.join(" "), " ", ldvalues);
				_editBoxMain.text = _editBoxMain.text ~ "\n"d;

				processInputAndAddToMain(txt);
			} else {
				addToHistory("Change tasks by number(s)");
				import std.algorithm: filter, canFind;
				import std.string: indexOf, strip;
				import std.ascii: digits;

				string idTxt = _editLineId.text.filter!(f => (digits ~ "-").canFind(f)).to!string.strip;
				immutable index = idTxt.indexOf("-");

				if (index != -1) {
					void errorMessage() {
						_editBoxMain.text = _editBoxMain.text ~ "\nSome thing wrong with selection input!"d;
					}
					if (index == 0 || index == idTxt.length) {
						errorMessage;
					} else {
						int[2] rangeStartAndEnd;

						try {
							rangeStartAndEnd = idTxt.split("-").to!(int[2]);
						} catch(Exception e) {
							errorMessage;

							return false;
						}

						auto from0 = rangeStartAndEnd[0], to0 = rangeStartAndEnd[1];
						if (from0 > to0) {
							import std.algorithm: swap;

							swap(from0, to0);
						}
						string strNums = "";
						foreach(num; from0 .. to0 + 1)
							strNums ~= " " ~ num.to!string;
						_editLineId.text = strNums.to!dstring;
						addToHistory("Using:", strNums, ", number", from0 != to0 ? "s" : "");
					}
				}

				int[] selection;
				try {
					selection = _editLineId.text.split.to!(int[]);
				} catch(Exception e) {
					_editBoxMain.text = _editBoxMain.text ~ "\nFailed!"d;

					return false;
				}

				_control.processInput(ldvalues, selection);
			}

            return true;
		};

		_editBoxMain.text = "Click the (Help) button\n".to!dstring;
		addToHistory("Welcome to ChronoLog");

/+
const Action ACTION_FILE_EXIT = new Action(IDEActions.FileExit, "MENU_FILE_EXIT"c, "document-close"c, KeyCode.KEY_X, KeyFlag.Alt);

        mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "MENU_FILE"));
        fileItem.add(ACTION_FILE_EXIT);
        mainMenuItems.add(fileItem);
+/
		_window.show();

		return 0;
    }

	auto processInputAndAddToMain(in string input) {
		import std.algorithm: canFind;

		if (_editLineComment.text.canFind(`"`)) {
			immutable errorCmt = "Invalid comment, it contains double quotes!"d;

			addToHistory(errorCmt);
			_editBoxMain.text = _editBoxMain.text ~ errorCmt;

			return false;
		}

		addToHistory(input);

		auto output = _control.processInput(input);

		if (output.length > 0) {
			_editBoxMain.text = _editBoxMain.text ~ (output ~ "\n").to!dstring;

			return true;
		}

		return false;
	}

	void addToHistory(T...)(in T args) {
		immutable status = upDateStatus(args).to!dstring;
		_editBoxHistory.text = _editBoxHistory.text ~ status;
		_textWidgetStatus.text = status;
	}
}
