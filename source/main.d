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
 * // |\ |---------\  |-----------------------\ |----\ |-------\ |--------\ |--------------------\
 * // 17 Achievement  Monday September 20, 2010 5:43pm -> 6:00pm 20 minutes First bit of paid work
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

//version = DUnit; // out of date library, I think

/**
	Title: Start of program
	Loads the task possibles from a text file, processes them and adds them to the task object.<br>
	Then creates a control object and runs its run method.
*/
mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
	scope(exit) {
		writeln;
		writeln(" ##");
		writeln("#  ");
		writeln("#  ");
		writeln("#  ");
		writeln(" ##");
		writeln;
	}
	
	const SCALE_FACTOR = 2.0f;

        // just in case, but dlangui package seems to import pretty much everything
        import dlangui.core.types;

        // pretty much self explanatory, where 96 DPI is "normal" 100% zoom
        // alternatively you can set it to your screen real DPI or PPI or whatever it is called now
        // however for 4k with 144 DPI IIRC I set it to 1.25 scale because 1.5 was too big and/or didn't match WPF/native elements
	overrideScreenDPI = cast(int)(96f * SCALE_FACTOR);

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
