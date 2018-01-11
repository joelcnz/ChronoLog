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
	import task, taskman, control;
}
/**
	Eg. displaying tasks. either the tasks that you choose from (TaskType.possibles) or the task done list (TaskType.done)
*/
enum TaskType {possibles, // list you choose from, done
			   done,
		   	   allDone}; // tasks you've added to the log
/**
	For displaying possibles collums
*/
enum Collum {left, right, straitDown};

const VERSION = `(Friday 11 3 2016). Noticed a random crash (with saving I think) :-\ 19.12.2014 => Also, not using 'fc' then"
	"sd has a weid effect, maybe some thing to do with 12 month I don't think 'cls' works for text tank "
		"(eg instead put eg lt109 and save the tank, this avoids repeats.)"`;
//const VERSION = `Thursday sd"11 9 2014" c"Looks like user input (as aposed to from a file) is working too."`;
//const VERSION = `Sunday sd"7 9 2014" c"Now can use it again. Still stuff doesn't work though."`;
//const VERSION = `Saturday sd"19 4 2014 - got some where"`;
//const VERSION = `Sunday sd"25 3 2014"`;
//const VERSION = `Monday sd"24 3 2014"`;
//const VERSION = `Sunday sd"23 3 2014"`;
//const VERSION = `Saturday sd"22 3 2014"`;
//const VERSION = `Friday sd"21 3 2014"`;
//const VERSION = `Thursday March 20, 2014`;
//const VERSION = `Wednesday st"2 0 34" March 19, 2014`;
//const VERSION = `Tuesday st"11 16 43" March 18, 2014`;
//const VERSION = `Monday et"15 50 51" March 17, 2014`;
//const VERSION = "Sunday [10:30pm] March 16, 2014";
//const VERSION = "Saturday [2:36.37pm] March 15, 2014";
//const VERSION = "Friday [4:06pm] March 14, 2014";
//const VERSION = "Wednesday March 12, 2014"; -------
//const VERSION = "Tuesday February 19, 2013";
//const VERSION = "Friday October 19, 2012";
//const VERSION = "Saturday October 22, 2011";
//const VERSION = "Tueday October 18, 2011";
//const VERSION = "Monday October 17, 2011";
//const VERSION = "Saturday October 15, 2011";
//const VERSION = "Friday October 14, 2011";
//const VERSION = "Thursday October 13, 2011";
//const VERSION = "Wednesday October 12, 2011";
//const VERSION = "Friday December 3, 2010";
//const VERSION = "Friday November 26, 2010";
//const VERSION = "Saturday October 23, 2010";
//const VERSION = "Wednesday October 13, 2010";
//const VERSION = "Tuesday October 12, 2010";
//const VERSION = "Sunday October 10, 2010";
//const VERSION = "Saturday October 9, 2010";
//const VERSION = "Friday October 1, 2010";
//const VERSION = "Thursday September 30, 2010";
//const VERSION = "Tuesday September 28, 2010";
//const VERSION = "Monday September 27, 2010";
//const VERSION = "Sunday September 26, 2010";

string timeString(DateTime time, bool includeSecond = false) {
	with(time) {
		auto secondText = second.to!string();

		return format( "[%s:%02s%s%s]",
				(hour == 0 || hour == 12 ? 12 : hour % 12), 
				 minute,
				 (includeSecond ? "." ~ (secondText.length == 1 ? "0" : "") ~ secondText : ""),
				(hour < 12 ? "am" : "pm") );
	}
}

void processCategory(ref TaskMan taskMan) {
	auto dummyDate = cast(DateTime)Clock.currTime();
	taskMan.resetCategorys();
	// load text file (format: "[3 digit number] [space gap] [task name]" eg. "123 Decided to go to bed"
	auto f = File("taskpossibles.txt","r");
	char[] buf; // tempory storage for raw data
	// keep track of what line is on for better information log (eg. if you had a line with nothing in it, it would tell you its line number)
	int line = 1; 

	static int getNum(in string str) {
		auto s = str.split()[0];

		//if (s.length) {
			return s.to!int();
		//}
	}

	string getLabel(in string str) {
		auto s = str.split()[1..$].join(" ");

		return s;
	}

	// cycle through text file line by line adding to the task manager
	while(f.readln(buf)) { // read a line and store the value in buf
		buf = stripRight(buf); // get rid of new line
		if (buf.length > 4) // check to see if line is long enough to be valid
			// add the two bits of data to the task manager the possible list
			//taskMan.addPossible(new Task(dummyDate, buf[0 .. 3].to!int, buf[4 .. $]));
			taskMan.addPossible(new Task(dummyDate, getNum(buf.idup), getLabel(buf.idup) ) );
		else
		{
			writeln("Hick. line: ", line); // print lines that can't be valid and show way line it's on
		}
		++line; // get ready for next line
	}
	
	f.close; // file processing done
}

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
	
	f.close;
	
	if (remove != -1) {
		taskMan.saveHidden("taskshidden.txt");
	}
}

unittest {
	mixin(test("1 == 1", "is one actually equal to one"));
	string s = string.init;
	mixin(test("s is null", "string is null"));
}
