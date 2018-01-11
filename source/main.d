//#not gotten to work with DUB
// I think I've done this - Need to create knew entries with each id in the list (control.d)

//#Hmm.. what time is it?
//# hourFromTime - says 7 for when it's 7pm, I think maybe 12 hours out, must try it in the morning.
//#file load
/// Title: Hack job to start with, all in one source file.
/// Date: September 20, 2010 12:00 -800
/**
 * Clearly defined:
 * Possible tasks = the list of tasks you choose from to add<br>
 * Done tasks = tasks you add to a list of things done.<br>
 * TaskMan stores the possible tasks and done tasks possible tasks, then done tasks, in that order.
 * Data structure:
 * ---
 # //                                           Optional start time
 * // Referance number                          |      Optional end time
 * // |                                         |      |         Optional time taken
 * // |  Task done    Date                      |      |         |          Optional comment
 * // |\ |---------\  |-----------------------\ |----\ |-------\ |--------\ |---------\
 * // 17 Achievement  Monday September 20, 2010 5:43pm -> 6:00pm 20 minutes Bit of work
 * // Binary form:
 * // (int for id) (int for string task length) (string task) (long for date and time etc) (int for hours minutes) (int for string length) (string comment)
 * I think now it has varibles for whether to show time of day or not. For start time, end time and time duration
 * ---
 * Only add done tasks:
 * ---
 * _taskMan ~= Task(...); // adds to done tasks
 * ---
 */
module main;

private {
	import std.conv;
	import std.stdio;
	import std.string;

	import base, gui, task, taskman;

	import dlangui;
	//import jtask.taskmanbb;
}

/+
//#not gotten to work with DUB
extern(C) char* readline(const(char)* prompt);
extern(C) void add_history(const(char)* prompt);

pragma(lib, "readline");
pragma(lib, "curses");
+/

//pragma(lib, "jtask");

//version = DUnit; // out of date library, I think

/**
	Title: Start of program
	Loads the task possibles from a text file, processes them and adds them to the task object.<br>
	Then creates a control object and runs its run method.
*/
mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
	TaskMan taskMan = new TaskMan; // handles the task objects
	
	processCategory(taskMan);
	tasksHidden(taskMan);
	Gui guj;
	guj.setup(taskMan);
	//Control control; // declare a control object
	//control.setup(taskMan); // pass task manager object to control methods

    // run message loop
    return Platform.instance.enterMessageLoop();
}
