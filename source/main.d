// I think I've done this - Need to create knew entries with each id in the list (control.d)

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

	import base, maingui, task, taskman;

}

void main(string[] args) {
	scope(exit) {
		writeln;
		writeln(" ##");
		writeln("#  ");
		writeln("#  ");
		writeln("#  ");
		writeln(" ##");
		writeln;
	}

	Main.init(args);

	g_RigWindow = new RigWindow();

	import std.string : chomp;
	import jmisc : gh;

	immutable fileName = "entryboxtexts.txt";
	enum Type {CATEGORY, GETSETS, COMMENT, COMMAND, ADD_CATERGORY_TICK_BOX}
	int i;
	foreach(data; File(fileName).byLine) {
		auto line = data.to!string.chomp;
		if (line.length)
			switch(i) with (Type) {
				default: gh(fileName ~ " - error"); return;
				case CATEGORY: g_RigWindow.getAppBox.getMainTextViewAndDown.getCategoryRefBox.getCatEntry.setText = line; break;
				case GETSETS: g_RigWindow.getAppBox.getMainTextViewAndDown.getCategoryRefBox.getRefEntry.setText = line; break;
				case COMMENT: g_RigWindow.getAppBox.getMainTextViewAndDown.getCommentEntryBox.getCommentEntry.setText = line; break;
				case COMMAND: g_RigWindow.getAppBox.getMainTextViewAndDown.getCommandEntryBox.getCommandEntry.setText = line; break;
				case ADD_CATERGORY_TICK_BOX:
					g_RigWindow.getAppBox.getMainTextViewAndDown.getCategoryRefBox.getCatCheckButton.setActive(line == "1");
				break;
			}
		i += 1;
	}
	if (i - 1 < Type.max.to!int) {
		gh(fileName ~ " - error");
		return;
	}

	Main.run();
}
