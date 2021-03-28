//#$ - 1 to remove the new line character
//#new get rid of new line characters
//#Maybe rename function
//#this
//cfl"first line%nlsecond line #%cn [%cl] %dd whole: %wd {%co} %in? st%st et%et%nl"

/**
	For stuff to be easier to access

Disabiguate(sp):
Possibles - from the ID list
dones - all the entries

Objectives:
Get it back to doing the stuff.

Get multi ID's with same content working.

Get sort working.
*/
module base;

public:
import gtk.Main;
import gtk.MainWindow;
import gtk.Grid;
import gtk.ComboBoxText;
import gtk.Box;
import gtk.Entry;
import gtk.Label;
import gtk.Button;
import gtk.CheckButton;
import gtk.TextTagTable;
import gtk.TextBuffer;
import gtk.TextView;
import gtk.Clipboard;
import gtk.Adjustment;
import gtk.ScrolledWindow;
import gtk.ViewPort;
import gtk.TextIter; // probably idle
import gtk.TextMark; // idle
import gtk.AccelGroup;
import gtk.MenuItem;
import gtk.Window;
import gtk.Widget;
import gtk.HeaderBar;

import gdk.Event;
import gdk.Keysyms;

private {
	import std.stdio;
	import std.string;
//	import std.c.time;
//	import std.date;
	import std.datetime;
	import std.string;
	import std.conv;

	import jmisc;
	import jtask.basebb;
	import maingui, task, taskman, control;
}

/**
	Eg. displaying tasks. either the tasks that you choose from (TaskType.possibles) or the task done list (TaskType.done)
*/
enum TaskType {possibles, // list you choose from, done
			   done,
		   	   allDone} // tasks you've added to the log
/**
	For displaying possibles collums
*/
enum Collum {left, right, straitDown}

/// Status
//const VERSION = `Saturday: 49 sd"30,5,2020" c"Started GtkD version of ChronoLog. Got all the widgets up."`;
const VERSION = `Sunday: 49 sd"31,5,2020" c"Finished this version of ChronoLog to a useable state."`;

/// Global for extra data that I couldn't hardly get otherwise
enum Clip {first, second, third}
string[3] g_clipboard; /// For getting more feed back //#this (g_clipboard[Clip.first] = task.to!string; )

RigWindow g_RigWindow;

class RigWindow : MainWindow
{
	private:
	string title = "Poorly Programmed Productions Presents: ChronoLog";
	AppBox appBox;
	TaskMan taskMan;
	Control control;
	//partnerTextViewMain;
	
	public:
	this()
	{
		super(title);
		addOnDestroy(&quitApp);
		
		appBox = new AppBox();
		add(appBox);

		taskMan = new TaskMan; // handles the task objects

		processCategory(taskMan);
		tasksHidden(taskMan);

        control.setup(taskMan);

		addOnKeyPress(&controlQCallBack);

		addToHistory("Welcome to ChronoLog!");

		setTitlebar(new MyHeaderBar());

		//immutable iconFile = "../Res/ballicon.png";
		immutable iconFile = "../Res/activitylog.png";
		setIconFromFile(iconFile);

		showAll();
	} // this()

	auto getControl() {
		return control;
	}

	auto getAppBox() {
		return appBox;
	}
	
	auto getTaskMan() {
		return taskMan;
	}

	auto processInputAndAddToMain(in string input) {
		import std.algorithm: canFind;

		auto comment() {
			return appBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry;
		}

		auto buffer() {
			return appBox.getMainTextViewAndDown.getMyTextViewMain.getBuffer;
		}

		if (comment.getText.canFind(`"`)) {
			immutable errorCmt = "Invalid comment, it contains double quotes!";

			addToHistory(errorCmt);
			buffer.setText(errorCmt);

			return errorCmt;
		}

		addToHistory(input);

		auto output = getControl.processInput(input);

		if (output.length > 0) {
			immutable text = buffer.getText;
			buffer.setText(text ~ "\n" ~ output);

			return output;
		}

		return "fail";
	}

	void addToHistory(T...)(in T args) {
		immutable status = jm_upDateStatus(args);
		auto buffer() {
			return appBox.getMainTextViewAndDown.getMyTextViewHistory.getBuffer;
		}
		auto statusl() {
			return appBox.getMainTextViewAndDown.getStatusBox.getStatusLabel;
		}
		immutable text = buffer.getText;

		buffer.setText(text ~ status);
		immutable capAt = 150;
		//#$ - 1 to remove the new line character
		statusl.setText =
			status[0 .. status.length > capAt ? capAt : $ - 1] ~ (status.length > capAt ? "..." : "");

		scrollToBottom(appBox.getMainTextViewAndDown.getMyTextViewHistory);
		scrollToBottom(appBox.getMainTextViewAndDown.getMyTextViewMain);
	}

	private:
	bool controlQCallBack(Event ev, Widget w)
	{
		if (ev.key.state == GdkModifierType.CONTROL_MASK &&
			ev.key.keyval == GdkKeysyms.GDK_q) {
			
			quitApp(w);

			return true;
		}
		
		return false;
	}

	void quitApp(Widget widget)
	{
		string exitMessage = "Bye.";

		File("mainwindow.txt", "w").write(appBox.getMainTextViewAndDown.getMyTextViewMain.getTextBuffer.getText);

		//#new get rid of new line characters
		import std.string : replace;
		immutable cmt = appBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry.getText.replace('\n', ' ');
		appBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry.setText = cmt != "" ? cmt : "";
			

		File("entryboxtexts.txt", "w").writeln(
			appBox.getMainTextViewAndDown.getCategoryRefBox.getCatEntry.getText ~ "\n" ~
			appBox.getMainTextViewAndDown.getCategoryRefBox.getRefEntry.getText ~ "\n" ~
			appBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry.getText ~ "\n" ~
			appBox.getMainTextViewAndDown.getCommandEntryBox.getCommandEntry.getText ~ "\n" ~
			(appBox.getMainTextViewAndDown.getCategoryRefBox.getCatCheckButton.getActive ? "1" : "0")
		);
		
		writeln(exitMessage);
		
		Main.quit();
		
	} // quitApp()

} // class TestRigWindow

//#Maybe rename function
/// Process categories
void processCategory(ref TaskMan taskMan) {
	auto dummyDate = cast(DateTime)Clock.currTime();
	taskMan.resetCategorys();
	// load text file (format: "[3 digit number] [space gap] [task name]" eg. "123 Decided to go to bed"
	auto f = File("taskpossibles.txt","r");
	char[] buf; // tempory storage for raw data

	static int getNum(in string str) {
		auto s = str.split()[0];

		return s.to!int();
	}

	string getLabel(in string str) {
		auto s = str.split()[1..$].join(" ");

		return s;
	}

	// keep track of what line is on for better information log (eg. if you had a line with nothing in it, it would tell you its line number)
	int line = 1; 
	// cycle through text file line by line adding to the task manager
	while(f.readln(buf)) { // read a line and store the value in buf
		buf = stripRight(buf); // get rid of new line
		if (buf.length > 4) // check to see if line is long enough to be valid
			// add the two bits of data to the task manager the possible list
			//taskMan.addPossible(new Task(dummyDate, buf[0 .. 3].to!int, buf[4 .. $]));
			taskMan.addPossible(new Task(dummyDate, getNum(buf.idup), getLabel(buf.idup) ) );
		else
		{
			writeln("Hick. line: ", line); // print lines that can't be valid and show what line it's on
		}
		line += 1; // get ready for next line
	}
	
	f.close; // file processing done
}

/// Add hidden tasks
void tasksHidden(ref TaskMan taskMan, int remove = -1) {
	taskMan.clearHidden();
	// Register hidden tasks
	char[] buf;
	auto f = File("taskshidden.txt","r");

	while(f.readln(buf)) {
		buf = stripRight(buf); // get rid of new line
		if (buf.length > 4) { // check to see if line is long enough to be valid
			if (remove == buf[0 .. 3].to!int)
				continue;
			taskMan.addHidden(buf[0 .. 3].to!int, buf[4 .. $].idup);
		}
	}
	
	if (remove != -1) {
		taskMan.saveHidden("taskshidden.txt");
	}
}

unittest {
	mixin(test("1 == 1", "is one actually equal to one"));
	immutable s = string.init;
	mixin(test("s is null", "string is null"));
}

void scrollToBottom(MyTextView textView) {
    Adjustment adj = textView.getVadjustment();
    auto dif = adj.getUpper() - adj.getPageSize();
    adj.setValue(dif);
    textView.setVadjustment(adj);
}
