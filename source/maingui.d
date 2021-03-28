//#new get rid of new line characters
//#want to stop the width changing with window resizing
module maingui;

import std.conv: text, to;
import std.traits: isSomeString;

import jmisc;

import base, control, taskman;

class MyHeaderBar : HeaderBar {
	bool decorationsOn = true;
	string title = "ChonoLog";
	string subtitle = "Poorly Programmed Productions";

	this() {
		super();
		setShowCloseButton(decorationsOn); // turns on all buttons: close, max, min
		version(Windows)
			setDecorationLayout("close,icon,maximize,minimize:minimize,maximize,icon"); // no spaces between button IDs
		version(OSX)
			setDecorationLayout("close,icon,maximize:maximize,icon,close");
		setTitle(title);
		setSubtitle(subtitle);
	}

} // class MyHeaderBar

class AppBox : Box { // Consists of main text view, and the stuff underneath, and buttons and stuff on the right
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;
	MainTextViewAndDown mainTextViewAndDown;
	StuffOnRight stuffOnRight;

	public:
	this() {
		super(Orientation.HORIZONTAL, globalPadding);

		mainTextViewAndDown = new MainTextViewAndDown();
		stuffOnRight = new StuffOnRight();

		//immutable width = 120; //#want to stop the width changing with window resizing
		//stuffOnRight.setSizeRequest(width, -1);

		packStart(mainTextViewAndDown, expand, fill, localPadding);
		packStart(stuffOnRight, expand, fill, localPadding);

		addOnKeyPress(&keySelectFocusCallBack);
	}

	auto getMainTextViewAndDown() {
		return mainTextViewAndDown;
	}

	bool keySelectFocusCallBack(Event ev, Widget w) {
		if (ev.key.state == GdkModifierType.CONTROL_MASK) {
			with(g_RigWindow)  switch(ev.key.keyval) {
				default: break;
				case GdkKeysyms.GDK_d: setFocus(stuffOnRight.getDateLabelAndEntryBox.getEntry); return true;
				case GdkKeysyms.GDK_i: setFocus(stuffOnRight.getTimeLabelEntryAndCheckBox.getEntry); return true;
				case GdkKeysyms.GDK_j: setFocus(stuffOnRight.getEndTimeLabelEntryAndCheckBox.getEntry); return true;
				case GdkKeysyms.GDK_o: setFocus(stuffOnRight.getDurationLabelAndEntryBox.getEntry); return true;
				case GdkKeysyms.GDK_g: setFocus(mainTextViewAndDown.getCategoryRefBox.getCatEntry); return true;
				case GdkKeysyms.GDK_h: setFocus(mainTextViewAndDown.getCategoryRefBox.getRefEntry); return true;
				case GdkKeysyms.GDK_b: setFocus(mainTextViewAndDown.getCommentEntryBox.getCommentEntry); return true;
				case GdkKeysyms.GDK_m: setFocus(mainTextViewAndDown.getCommandEntryBox.getCommandEntry); return true;
			}
		}

		return false;  
	}
}

class MainTextViewAndDown : VerticalBox {
	private:
	ScrolledTextWindow scrolledTextWindowMain;
	HistoryLabelBox historyLabelBox;
	ScrolledTextWindow scrolledTextWindowHistory;
	CategoryRefBox categoryRefBox;
	CategorySetBox categorySetBox;
	CommentEntryBox commentEntryBox;
	CommandEntryBox commandEntryBox;
	StatusBox statusBox;

	public:
	this() {
		scrolledTextWindowMain = new ScrolledTextWindow();
		historyLabelBox = new HistoryLabelBox();
		scrolledTextWindowHistory = new ScrolledTextWindow();
		categoryRefBox = new CategoryRefBox();
		categorySetBox = new CategorySetBox();
		commentEntryBox = new CommentEntryBox();
		commandEntryBox = new CommandEntryBox(this);
		statusBox = new StatusBox();

		immutable width = 1_100, height = 450;
		scrolledTextWindowMain.setMinContentWidth(width);
		scrolledTextWindowMain.setMinContentHeight(height);

		immutable height2 = 100;
		scrolledTextWindowHistory.setMinContentWidth(width);
		scrolledTextWindowHistory.setMinContentHeight(height2);

		import std.file;
		string content = readText("mainwindow.txt");
		if (content.length) scrolledTextWindowMain.getMyTextView.getTextBuffer.setText = content;

		commentEntryBox.getCommentEntry.setPlaceholderText("(Ctrl + B)");
		commandEntryBox.getCommandEntry.setPlaceholderText("(Ctrl + M)");

		packStart(scrolledTextWindowMain, expand, fill, localPadding);
		packStart(historyLabelBox, expand, fill, localPadding);
		packStart(scrolledTextWindowHistory, expand, fill, localPadding);
		packStart(categoryRefBox, expand, fill, localPadding);
		packStart(categorySetBox, expand, fill, localPadding);
		packStart(commentEntryBox, expand, fill, localPadding);
		packStart(commandEntryBox, expand, fill, localPadding);
		packStart(statusBox, expand, fill, localPadding);
	}

	auto getMyTextViewMain() {
		return scrolledTextWindowMain.myTextView;
	}

	auto getMyTextViewHistory() {
		return scrolledTextWindowHistory.myTextView;
	}

	auto getCategoryRefBox() {
		return categoryRefBox;
	}

	auto getCategorySetBox() {
		return categorySetBox;
	}

	auto getCommentEntryBox() {
		return commentEntryBox;
	}

	auto getCommandEntryBox() {
		return commandEntryBox;
	}

	auto getScrolledTextWindowMain() {
		return scrolledTextWindowMain;
	}

	auto getStatusBox() {
		return statusBox;
	}
}

class CategoryRefBox : HorizontalBox
{
	private:
	Label catLabel;
	string catString = "Add categories:";
	Entry catEntry;
	CheckButton catCheckButton;
	Label refLabel;
	string refLebelText = "Get/Set Reference(s):";
	Entry refEntry;
	string refEntryContains = "0";

	public:
	this() {
		catLabel = new Label(catString);
		catEntry = new Entry();
		catCheckButton = new CheckButton();
		refLabel = new Label(refLebelText);
		refEntry = new Entry(refEntryContains);

		catCheckButton.setActive(true);
		immutable width = 70;
		catEntry.setSizeRequest(width, -1);
		refEntry.setSizeRequest(width * 2, -1);

		catEntry.setPlaceholderText("(Ctrl + G)");
		refEntry.setPlaceholderText("(Ctrl + H)");

		expand = fill = false;
		packStart(catLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(catEntry, expand, fill, localPadding);
		packStart(catCheckButton, expand, fill, localPadding);
		expand = fill = false;
		packStart(refLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(refEntry, expand, fill, localPadding);
	}

	auto getCatCheckButton() {
		return catCheckButton;
	}

	auto getCatEntry() {
		return catEntry;
	}

	auto getRefEntry() {
		return refEntry;
	}
}

class CategorySetBox : HorizontalBox
{
	private:
	Label catLabel;
	string catString = "Category:";
	Label catSelectLabel;
	string catSelectLebelString = "(none set)";

	public:
	this() {
		catLabel = new Label(catString);
		catSelectLabel = new Label(catSelectLebelString);

		expand = fill = false;
		packStart(catLabel, expand, fill, localPadding);
		packStart(catSelectLabel, expand, fill, localPadding);
	}

	auto getCatSelectLabel() {
		return catSelectLabel;
	}
}

class CommentEntryBox : HorizontalBox {
	private:
	Label commentLabel;
	string commentString = "Comment:";
	Entry commentEntry;
	MainTextViewAndDown partnerMainTextViewAndDown;

	public:
	this() {
		commentLabel = new Label(commentString);
		commentEntry = new Entry();

		expand = fill = false;
		packStart(commentLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(commentEntry, expand, fill, localPadding);

		//addPartner(mainTextViewAndDown);
	}
/+
	void addPartner(MainTextViewAndDown mainTextViewAndDown) {
		partnerMainTextViewAndDown = mainTextViewAndDown;
	}
+/
	void doEnter(Entry a) {
//		g_RigWindow.separateCommands(commandEntry.getText);
//		commandEntry.setText("");
	}

	auto getCommentEntry() {
		return commentEntry;
	}
}

class CommandEntryBox : HorizontalBox {
	private:
	Label commandLabel;
	string commandString = "Command Input:";
	Entry commandEntry;
	MainTextViewAndDown partnerMainTextViewAndDown;

	public:
	this(MainTextViewAndDown mainTextViewAndDown) {
		commandLabel = new Label(commandString);
		commandEntry = new Entry();

		expand = fill = false;
		packStart(commandLabel, expand, fill, localPadding);
		expand = fill = true;
		packStart(commandEntry, expand, fill, localPadding);

		commandEntry.addOnActivate(&doEnter);

		addPartner(mainTextViewAndDown);
	}

	void addPartner(MainTextViewAndDown mainTextViewAndDown) {
		partnerMainTextViewAndDown = mainTextViewAndDown;
	}

	void doEnter(Entry a) {
		auto buffer() {
			return partnerMainTextViewAndDown.getScrolledTextWindowMain.getMyTextView.getTextBuffer;
		}
		immutable text = buffer.getText;

		g_RigWindow.getTaskMan.resetViewTasks;
		buffer.setText(text ~ g_RigWindow.processInputAndAddToMain(commandEntry.getText));
//		commandEntry.setText("");
	}

	auto getCommandEntry() {
		return commandEntry;
	}
}

class StatusBox : HorizontalBox {
	private:
	Label statusLabelLabel;
	string statusLabelString = "Status:";
	Label statusLabel;
	string statusString = "Loading..";

	public:
	this() {
		statusLabelLabel = new Label(statusLabelString);
		statusLabel = new Label(statusString);

		expand = fill = false;
		packStart(statusLabelLabel, expand, fill, localPadding);
		packStart(statusLabel, expand, fill, localPadding);
	}

	auto getStatusLabel() {
		return statusLabel;
	}
}

class StuffOnRight : VerticalBox {
	private:
	int width = 30;
	Button getButton;
	string getString = "Get";
	LabelAndEntryBox dateLabelAndEntryBox;
	string dateString = "Date:";
	string initString = "Loading..";
	LabelEntryAndCheckBox timeLabelEntryAndCheckBox;
	string timeString = "Time:";
	LabelEntryAndCheckBox endTimeLabelEntryAndCheckBox;
	string endTimeString = "End Time:";
	LabelAndEntryBox durationLabelAndEntryBox;
	string durationString = "Duration:";
	Button setButton;
	string setString = "Set";
	LabelBox deviderLabelBox;
	string deviderLabelBoxString = "< - >";
	Button processButton;
	string processString = "Process!";
	Button saveButton;
	string saveString = "Save";
	Button viewCategoriesButton;
	string viewCategoriesString = "View Catergories";
	Button viewTimeButton;
	string viewTimeString = "Time";
	Button viewHelpButton;
	string viewHelpString = "Help";
	Button clearButton;
	string clearString = "Clear";
	Button bottomButton;
	string bottomString = "Ta-Bottom";

	public:
	this() {
		getButton = new Button(getString, &getOnClick);
		dateLabelAndEntryBox = new LabelAndEntryBox(dateString);
		timeLabelEntryAndCheckBox = new LabelEntryAndCheckBox(timeString);
		endTimeLabelEntryAndCheckBox = new LabelEntryAndCheckBox(endTimeString);
		durationLabelAndEntryBox = new LabelAndEntryBox(durationString);
		setButton = new Button(setString, &setOnClick);
		processButton = new Button(processString, &processOnClick);
		saveButton = new Button(saveString, &saveOnClick);
		viewCategoriesButton = new Button(viewCategoriesString, &viewCategoriesOnClick);
		viewTimeButton = new Button(viewTimeString, &viewTimeOnClick);
		viewHelpButton = new Button(viewHelpString, &viewHelpOnClick);
		clearButton = new Button(clearString, &clearButtonOnClick);
		bottomButton = new Button(bottomString, &bottomButtonOnClick);

		import std.datetime: DateTime, Clock;

		auto dt = cast(DateTime)Clock.currTime();
		immutable time0 = text(dt.hour, ":", dt.minute, ":", dt.second);

		dateLabelAndEntryBox.getEntry.setText = text(dt.day, ".", cast(int)dt.month, ".", dt.year);
		timeLabelEntryAndCheckBox.getEntry.setText = time0;
		endTimeLabelEntryAndCheckBox.getEntry.setText = time0;
		durationLabelAndEntryBox.getEntry.setText = "0:0:0";

		void addDevider() {
			deviderLabelBox = new LabelBox(deviderLabelBoxString);
			packStart(deviderLabelBox, expand, fill, localPadding);
		}

		dateLabelAndEntryBox.getEntry.setPlaceholderText("(Ctrl + D)");
		timeLabelEntryAndCheckBox.getEntry.setPlaceholderText("(Ctrl + I)");
		endTimeLabelEntryAndCheckBox.getEntry.setPlaceholderText("(Ctrl + J)");
		durationLabelAndEntryBox.getEntry.setPlaceholderText("(Ctrl + O)");

		expand = fill = false;
		packStart(getButton, expand, fill, localPadding);
		packStart(dateLabelAndEntryBox, expand, fill, localPadding);
		packStart(timeLabelEntryAndCheckBox, expand, fill, localPadding);
		packStart(endTimeLabelEntryAndCheckBox, expand, fill, localPadding);
		packStart(durationLabelAndEntryBox, expand, fill, localPadding);
		packStart(setButton, expand, fill, localPadding);
		addDevider;
		packStart(processButton, expand, fill, localPadding);
		addDevider;
		packStart(saveButton, expand, fill, localPadding);
		addDevider;
		packStart(viewCategoriesButton, expand, fill, localPadding);
		packStart(viewTimeButton, expand, fill, localPadding);
		packStart(viewHelpButton, expand, fill, localPadding);
		addDevider;
		packStart(clearButton, expand, fill, localPadding);
		addDevider;
		packStart(bottomButton, expand, fill, localPadding);
	}

	auto getDateLabelAndEntryBox() {
		return dateLabelAndEntryBox;
	}

	auto getTimeLabelEntryAndCheckBox() {
		return timeLabelEntryAndCheckBox;
	}

	auto getEndTimeLabelEntryAndCheckBox() {
		return endTimeLabelEntryAndCheckBox;
	}

	auto getDurationLabelAndEntryBox() {
		return durationLabelAndEntryBox;
	}

	void getOnClick(Button b) {
		auto reference() {
			return g_RigWindow.getAppBox.getMainTextViewAndDown.getCategoryRefBox.getRefEntry;
		}
		auto buffer() {
			return g_RigWindow.getAppBox.getMainTextViewAndDown.getMyTextViewMain.getBuffer;
		}
		g_RigWindow.addToHistory("Get pressed for ", reference.getText);
		int id;
		try {
			id = reference.getText.to!int;
		} catch(Exception e) {
			immutable text = buffer.getText;
			buffer.setText(text ~ "\nCouldn't read reference input, (maybe more than one number there).");

			return;
		}

		auto task = g_RigWindow.getTaskMan.getTask(id); 
		if (task is null) {
			immutable error = "Task # out of range! (0-" ~ (g_RigWindow.getTaskMan.numberOfTasks - 1).to!string ~ ")";

			immutable text = buffer.getText;
			buffer.setText(text ~ "\n" ~ error);
			g_RigWindow.addToHistory(error);

			return;
		} else {
			auto label() {
				return g_RigWindow.getAppBox.getMainTextViewAndDown.getCategorySetBox.getCatSelectLabel;
			}
			auto comment() {
				return g_RigWindow.getAppBox.getMainTextViewAndDown.commentEntryBox.getCommentEntry;
			}
			label.setText = task.id().to!string ~ " - " ~ task.taskString;
			dateLabelAndEntryBox.getEntry.setText = text(task.dateTime.day, " ", cast(int)task.dateTime.month, " ", task.dateTime.year);

			timeLabelEntryAndCheckBox.getCheckButton.setActive = task.displayTimeFlag;
			if (task.displayTimeFlag)
				timeLabelEntryAndCheckBox.getEntry.setText =
					text(task.dateTime.hour, " ", task.dateTime.minute, " ", task.dateTime.second);
			else
				timeLabelEntryAndCheckBox.getEntry.setText = "";

			endTimeLabelEntryAndCheckBox.getCheckButton.setActive = task.displayEndTimeFlag;
			if (task.displayEndTimeFlag)
				endTimeLabelEntryAndCheckBox.getEntry.setText = text(task.endTime.hour, " ", task.endTime.minute, " ", task.endTime.second);
			else
				endTimeLabelEntryAndCheckBox.getEntry.setText = "";

			if (task.timeLength.hours ==0 && task.timeLength.minutes == 0 && task.timeLength.seconds == 0)
				durationLabelAndEntryBox.getEntry.setText = "";
			else
				durationLabelAndEntryBox.getEntry.setText = text(task.timeLength.hours, " ", task.timeLength.minutes, " ", task.timeLength.seconds);

			if (task.comment == "")
				comment.setText = "";
			else
				comment.setText = task.comment();
		}
	} // get on click

	void clearButtonOnClick(Button b) {
		g_RigWindow.getTaskMan.resetViewTasks;
		g_RigWindow.getAppBox.getMainTextViewAndDown.getScrolledTextWindowMain.getMyTextView.getTextBuffer.setText = "";
		g_RigWindow.addToHistory("Main edit box cleared");
	}

	void viewHelpOnClick(Button b) {
		g_RigWindow.processInputAndAddToMain("help");
		g_RigWindow.addToHistory("View help");
	}

	void viewTimeOnClick(Button b) {
		g_RigWindow.processInputAndAddToMain("time");
		g_RigWindow.addToHistory("View current time");
	}

	void viewCategoriesOnClick(Button b) {
		g_RigWindow.processInputAndAddToMain("viewCategories");
	}

	void saveOnClick(Button b) {
		g_RigWindow.processInputAndAddToMain("save");
	}

	void processOnClick(Button b) {
		string text = g_RigWindow.getAppBox.getMainTextViewAndDown.getScrolledTextWindowMain.getMyTextView.getTextBuffer.getText;
		string result = g_RigWindow.getControl.processCommandsFromTextFileOrEditBox(text);

		g_RigWindow.addToHistory("Process button pressed..");
		g_RigWindow.getAppBox.getMainTextViewAndDown.getScrolledTextWindowMain.getMyTextView.getTextBuffer.
			setText(text ~ "\n" ~ result);
	}

	void setOnClick(Button b) {
		import std.string: split, join, format;
		auto loadValues() {
			assert(dateLabelAndEntryBox);
			assert(timeLabelEntryAndCheckBox.getCheckButton);
			assert(timeLabelEntryAndCheckBox.getEntry);
			assert(endTimeLabelEntryAndCheckBox.getCheckButton);
			assert(durationLabelAndEntryBox.getEntry);
			assert(g_RigWindow.getAppBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry);
			assert(g_RigWindow.getAppBox.getMainTextViewAndDown.getCommentEntryBox);

			//#new get rid of new line characters
			import std.string : replace;
			g_RigWindow.getAppBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry.setText = 
				g_RigWindow.getAppBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry.getText.replace('\n', ' ');

			//             Set Date
			//             | Start time
			//             | | End time
			//             | | | length of time
			//             | | | | comment
			//             | | | | |
			return format!`%s%s%s%sc"%s"`
					(text(`sd"`, dateLabelAndEntryBox.getEntry.getText, `" `),
					timeLabelEntryAndCheckBox.getCheckButton.getActive ?
						text(`st"`, timeLabelEntryAndCheckBox.getEntry.getText, `" `) : "",
					endTimeLabelEntryAndCheckBox.getCheckButton.getActive ?
						text(`et"`, endTimeLabelEntryAndCheckBox.getEntry.getText, `" `) : "",
					g_RigWindow.getControl.for3Nums(durationLabelAndEntryBox.getEntry.getText) != "0 0 0" ?
						text(`l"`, durationLabelAndEntryBox.getEntry.getText, `" `) : "",
					g_RigWindow.getAppBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry.getText);
		}
		import std.stdio;
		writeln(loadValues);
		immutable ldvalues = loadValues;
		auto catRefBox() {
			return g_RigWindow.getAppBox.getMainTextViewAndDown.getCategoryRefBox;
		}
		auto refEntry() {
			return g_RigWindow.getAppBox.getMainTextViewAndDown.categoryRefBox.getRefEntry;
		}
		auto mainTextViewBuffer() {
			return g_RigWindow.getAppBox.getMainTextViewAndDown.getMyTextViewMain.getBuffer;
		}

		if (catRefBox.getCatCheckButton.getActive) {
			immutable txt = text(catRefBox.getCatEntry.getText.split.join(" "), " ", ldvalues);
			immutable text = mainTextViewBuffer.getText;

			mainTextViewBuffer.setText(text ~ "\n");

			g_RigWindow.processInputAndAddToMain(txt);
		} else {
			g_RigWindow.addToHistory("Change tasks by number(s)");
			import std.algorithm: filter, canFind;
			import std.string: indexOf, strip;
			import std.ascii: digits;

			string idTxt = refEntry.getText.filter!(f => (digits ~ "-").canFind(f)).to!string.strip;
			immutable index = idTxt.indexOf("-");

			if (index != -1) {
				void errorMessage() {
					immutable text = mainTextViewBuffer.getText;
					mainTextViewBuffer.setText(text ~ "\nSome thing wrong with selection input!");
				}
				if (index == 0 || index == idTxt.length) {
					errorMessage;
				} else {
					int[2] rangeStartAndEnd;

					try {
						rangeStartAndEnd = idTxt.split("-").to!(int[2]);
					} catch(Exception e) {
						errorMessage;

						return;
					}

					auto from0 = rangeStartAndEnd[0], to0 = rangeStartAndEnd[1];
					if (from0 > to0) {
						import std.algorithm: swap;

						swap(from0, to0);
					}
					string strNums = "";
					foreach(num; from0 .. to0 + 1)
						strNums ~= (num != from0 ? " " : "") ~ num.to!string;
					refEntry.setText = strNums;
					
					g_RigWindow.addToHistory("Using:", strNums, ", number", from0 != to0 ? "s" : "");
				}
			}

			int[] selection;
			try {
				selection = refEntry.getText.split.to!(int[]);
			} catch(Exception e) {
				immutable text = mainTextViewBuffer.getText;
				mainTextViewBuffer.setText(text ~ "\nFailed!");

				return;
			}

			g_RigWindow.getControl.processInput(ldvalues, selection);
		} // else
	} // void setOnClick(Button b)

	void bottomButtonOnClick(Button b) {
		scrollToBottom(g_RigWindow.getAppBox.getMainTextViewAndDown.getMyTextViewHistory);
		scrollToBottom(g_RigWindow.getAppBox.getMainTextViewAndDown.getMyTextViewMain);
	}
}

class LabelAndEntryBox : HorizontalBox {
	private:
	Label label;
	Entry entry;

	public:
	this(string labelString) {
		label = new Label(labelString);
		entry = new Entry();

		expand = fill = false;
		packStart(label, expand, fill, localPadding);
		expand = fill = true;
		packStart(entry, expand, fill, localPadding);
	}

	auto getEntry() {
		return entry;
	}
}

class LabelEntryAndCheckBox : HorizontalBox {
	private:
	Label label;
	Entry entry;
	CheckButton checkButton;

	public:
	this(string labelString) {
		label = new Label(labelString);
		entry = new Entry();
		checkButton = new CheckButton();

		expand = fill = false;
		packStart(label, expand, fill, localPadding);
		expand = fill = true;
		packStart(entry, expand, fill, localPadding);
		expand = fill = false;
		packStart(checkButton, expand, fill, localPadding);
	}

	auto getEntry() {
		return entry;
	}

	auto getCheckButton() {
		return checkButton;
	}
}

class LabelBox : VerticalBox {
	private:
	Label label;

	public:
	this(string labelString) {
		label = new Label(labelString);

		expand = fill = false;
		packStart(label, expand, fill, localPadding);
	}
}

class HistoryLabelBox : HorizontalBox {
	private:
	Label historyLabel;

	public:
	this() {
		historyLabel = new Label("History:");

		expand = fill = false;
		packStart(historyLabel, expand, fill, localPadding);
	}
}

class VerticalBox : Box
{
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;

	public:
	this()
	{
		super(Orientation.VERTICAL, globalPadding);
		
	} // this()
	
} // class VerticalBox

class HorizontalBox : Box
{
	private:
	bool expand = true, fill = true;
	uint globalPadding = 5, localPadding = 5;

	public:
	this()
	{
		super(Orientation.HORIZONTAL, globalPadding);
		
	} // this()
	
} // class HorizontalBox

class ScrolledTextWindow : ScrolledWindow {
	MyTextView myTextView;
	
	this()
	{
		super();
		
		myTextView = new MyTextView("");
		add(myTextView);
		
	} // this()

	auto getMyTextView() {
		return myTextView;
	}
}

class MyTextView : TextView
{
	private:
	TextBuffer textBuffer;
	string _content;
	//TextIter textIter;
	
	public:
	this(string content)
	{
		super();
		textBuffer = getBuffer();
		//textIter = new TextIter();
		_content = content;
		setWrapMode(GtkWrapMode.WORD);

		textBuffer.setText(_content);
	}

	auto getTextBuffer() {
		return textBuffer;
	}

/+
	auto getTextIter() {
		return textIter;
	}
	+/
} // class MyTextView
