//#need to be able to do like this - eg. `r"0 1 2"` to wipe three off
//#I don't know what's supposed to happen here
//#E.g. if you miss c for comment ("got up") it just ignores it, it should abort

//#more work, maybe put view instead
//#a hack - calls doCommand twice! but I can't see 2 calls
//#not work eg Error: found '10' when expecting ',' etc
//#here
//#looks similer to base.timeString(DateTime time, bool includeSecond = false) function
//#but doesn't have the day of the week, and different layout
//#here for input
// Old -> Program broken :-/ (19 March 2014, before this day too)

//#put this in
//#may remove
//#only catergory numbers
//#stores each segment eg. 'st"10 20 0"' 'c"Went to bed after programming"'

//#crashes with numbers
//#what?
//#not sure about strip
//#Hmmm
//#use _autoInput.length for the number of items
//#bit different
//#strip didn't fix it. What is the point of this?
//#crash with more than one character
//#not working properly
//#here
//#list of id numbers - I'm not sure to use this
//#Maybe add task entries here for list or 1 id
//#to utilize
//#new. make an array of cat numbers
//#See here, for thinking out
//#don't know about this
//#tricky
//#note, looks for a number only at the start position, pos 0
//#muli number for adding category's needed!
//#more work
//#need st and et [# ]
//#untested 19 Aug 2013
//#commands in a row
//#can terminate, must fix!
//#had to add string to (a)
//#new
//#was bug here, still a bug on Lukes version
//#comes up with a warning about break being not reachable
//# what value is that?
//#why not '""'
//#not sure about the '~ " "' maybe put a optional parameter to this function
//#change load done tasks
/+
32 76 c"Up dunno" st"8 4 0"
et"9 0 0"
		
	string bigInput;
	if starts with number {
		if bigInput
			foreach(add; _adds) {
				_TaskLog ~= new Task();
				
			}
		get numbers to _adds
		bigInput ~= input
	} else {
		bigInput ~= " "~input;
	}
+/



/+
1#
This program is a diary. You can take imput from a text file and seperate it into the program where you
can do different taskes

2#
Build up a text file in the right format.
Run from the terminal.
Enter fc"feb22y14" (for example)
Enter 'sort' - to sort by date (and time)
Enter 'sv' to save
So, gather data, process data, sort it and save it.abstract

#3

+/

/*
	Time is altered when added, (eg. saved half a day altered, so now alteration when tasks loaded)

Put the numbers in for each possible (categrey(sp)) and index numbers.
Put in more data. (eg st"8 0 0" et"12 0 0" c"Upright!"). Editing with each index number.
*/

/+
//#See here, for thinking out

Two things:
1) Add, each number in list, new done entries
2) Go through each current list and set stuff

1 2 3 - first letter in string has to be a number!
1 added, 2 added 3 added. >1,000 1,001 1,002 c"Head phones worked well."
1000 1 c"Head phones worked well."
1001 2 c"Head phones worked well."
1002 3 c"Head phones worked well."

---

1 2 3 - input
create 3 catergory under adds = [1,2,3] - result
st"1 2 3" - input
go thru adds giving each category given the same data

At what point does it fail?

8000 label date etc - selection number
8000 37 nap - task id

Each time you change an item, we don't want to keep adding new entries, just edit the selection number(s)

1000 

Start:
1 2 c"Top" st"1 2 3"

add 1 and 2

st = 0, ed = 0
ced = 'c'
ed++
line[st..ed+1] = `c"`
Is now ced = '"' switch to quote function - find end or second '"'


+/

module control;

//debug = 5;

private
{
	import std.stdio;
	import std.string;
	import std.conv;
	import std.datetime;
	import std.ascii;
	import std.algorithm;
	import std.file;
	import std.path;
	import std.process;

	import arsd.terminal;
//	import dunit;
	import jmisc;
	import jtask.basebb;
	import base, gui, main, taskman, task;
}

//immutable jechoState = false;

//version=CompileFiles;
/**
	Title: Main command line control
	eg. add tasks done, save and load, show tasks done
*/
struct Control {
private:
//	public mixin TestMixin;
	int _commandCount;
	TaskMan _taskMan; // instance variable - in charge of the tasks
	enum InputType {userInput, autoInput};
	Control.InputType _inputType; //#bit different
	struct AutoInput {
		string command;
	}
	AutoInput[] _autoInput; //#use _autoInput.length for the number of items
	int _autoInputPos; //#to utilize

	string[] _autoLines; // for like 'fc'

	//int recNum, string command, int[] parameterNumbers, string parameterString, bool isNumber, ref bool done) {
	//int _recNum;
	string _command;
	string _bigInput;
	string _type;
	int[] _parameterNumbers;
	int[] _selectNumbers;
	string _parameterString;
	bool _isNumber;
	bool _done;
	//bool _selected; //#may remove

	DateTime _dateTime, // start time (and date)
		/+ _time +/ _endTime; // for getting duration (eg. how long a task too to do)
	int[] _adds; // catergory list
	string[] _segments;
	int[] _recNums; // the number you use to select from the list of done tasks
	enum Switch { alphaNum, space, quote }; // for separateCommands method
	int _catPos;
	//bool _addIds;

	//int[] parameterNumbers;
	//string _parameterString;

	/+
	 + In "1 2 3" out [1, 2, 3]
	 +/
	//Note has to have a number at the start
	int[] arrayCatNumbers(/* cut the numbers off the start */ ref string line) {
		//writeln("arrayCatNumbers start");
		//#new. make an array of cat numbers
		alias isDigit = std.ascii.isDigit;

		char[] addList; //#list of id numbers - I'm not sure to use this

		if (line.length > 0 && isDigit(line[0])) { //#note, looks for a number only at the start position, pos 0
			//writeln("arrayCatNumbers in if");
			// add list for each number with task
			char c = line[0];
			int p = 0; // p - position

			//bool is number or space and not reached the last char
			bool isValid() {
				if (c == ' ')
					return true;
				return p < line.length && isDigit(c); // return true if either p is not at the end, and c is a digit
			}

			while(isValid()) { // will be valid at the start (a number)
				//mixin(trace("/+ while(isValid()) start +/ c"));
				c = line[p]; // grab a charactor from the line of charactors
				if (! isValid()) {
					addList = addList.strip();
					/+
					while(! c.isDigit()) {
						p--;
						c = line[p];
					}
					+/

					break;
				}
				addList ~= c; // keep adding charactors
				//mixin(trace("/+ while(isValid()) end +/ c"));
				p++; // move to the next position
			}
			p--;

			line = line[p .. $].strip(); // remove the used part of line (eg remove the number(s) at the start of line)

			//try {
				//writeln("_adds");
				//mixin(traceLine("addList"));
				//foreach(n; addList)
				//	mixin(trace("_adds ~= n"));
				//_adds = to!(int[])(addList.split(" "));
				//mixin(trace("addList"));
//				_adds.length = 0;
//				foreach(n; addList.split)
//					ns ~= n.to!int;
				//result = addList.idup.split.to!(int[]);
			//} catch(Exception e) {
			//	writeln(`Invalid (_adds = to!(int[])(addList.split(" "));) - failed`);
			//	return [0];
			//}

			_recNums.length = 0;
			//do item number
			//foreach(recNum; 0 .. _adds.length)
			//	_recNums ~= cast(int)(_taskMan.doneTasks + _recNum); // doneTasks - build up tasks
		}

		return addList.split.to!(int[]);
	} // arrayCatNumbers
public:
	@property ref TaskMan taskMan() { return _taskMan; }

	void setup(TaskMan taskMan) {
		_dateTime = cast(DateTime)Clock.currTime();

		_taskMan = taskMan;
		_taskMan.loadDoneTasks("tasklog.bin");
	}


	unittest {
		import std.range;
		writeln("-".replicate(10));

		auto strNums = "1 2 3";
		int total;
		foreach(num; strNums.split.to!(int[]))
			total += num;
		mixin(trace("total"));
	}

	/**
	 * Take a string of commands, and separate them
	 */
	string[] separateCommands(string line) {

		_segments.length = 0; //#stores each segment eg. 'st"10 20 0"' 'c"Went to bed after programming"'

		string[] result;
		Switch sw = Switch.alphaNum; // letters and numbers
		//Switch sw = Switch.space;
		bool done = false;
		int st = 0, ed = 0;
		char ced = 'X';


		//1 2 3 c"House"
		//c"House"
		// collect letters and numbers changing to doQuote on quote. stopping at end
		//          space
		// alphaNum |alphaNum
		// | quote  ||quote
		// | |      |||
		// [][     ]||[     ]
		// st"1 2 3" c"House"
		void doAlphaNum() {
			/+
			find all the number
			+/

			if (ced == '"') {
				sw = Switch.quote,
				ed++;
			} else {
				if (ed == line.length || ! ced.isAlphaNum() || ced == ' ') {
					//#Hmmm
					if (st > ed) {
						ed = st;
						//writeln("*this* Error: (", line, ')');
					} else {
						result ~= line[st .. ed]; // superceeded(sp)
						//mixin(trace("line[st .. ed]"));
						st = ed + 1;

						if (ed >= line.length) {
							done = true;
						}
						else {
							if (ced == ' ') {
								sw = Switch.space;
							}
						}
					}
				}
				else
					ed++;
			}

		//	updateProcess();
		} // doAlphaNum


		// c"House"
		//#not sure if should get rid of this
		void doSpace() {
			/+
			 + if end pos is at the end, then quit out
			 + if char a number or a quotes then set the start pos to the end pos, and change the switch to the alpha numbers.
			 + move the end pos along
			 +/
			if (ed == line.length) {
				return;
			}
			//if (ced.isAlphaNum() || ced == '"') {
			if (ced.isAlphaNum())
			    sw = Switch.alphaNum;

			ed++;

		//	updateProcess();
		} // doSpace

		void doQuote() {

			/+
			 + if a quotes or end pos is at the end of the line
			 + 		if end less than the line end the changed the result for between the quotes
			 + 		and set start pos to passed the end pos and change the switch setting to space
			 +/
			//line = line.strip();
			if (ced == '"' || ed == line.length) {
				if (ed < line.length) {
					result ~= line[st .. ed+1].strip(); // append a string
					st = ed + 1; // new start
					sw = Switch.space;
				}
			}
			ed++;

		//	updateProcess();
		} // doQuote

		while(! done) {
			if (ed == line.length)
				break; // break out of while loop
			ced = line[ed];
			with(Switch)
				final switch(sw) {
					case alphaNum:
						doAlphaNum();
					break;
					case space:
						doSpace();
					break;
					case quote:
						doQuote();
					break;
				}
		}

		return (_segments = result);
	} // function separate files ?

	auto processInput(string input, int[] selection = []) {
	//#Maybe add task entries here for list or 1 id
		//writeln("TimeLog - Main menu (h for help) * * *"); // main prompt display
		//input = id.to!string~" "~strip(readln); // get input prepare it and store it in the input variable string
		//#here for input
		//write("D>"); input = readln().strip(); // get input prepare it and store it in the input variable string
		//input = ter.getline("D>");
		//writeln;
		//writeln("input: (", input, ')');
		std.file.append("errorlog.txt", input ~ "\n");
		//#commands in a row
		//_autoInput.length = 0;

		if (selection.length == 0) {
			_selectNumbers.length = 0;
			// if the input starts as a digit
			if (input.length > 0 && input[0].isDigit) { //#only catergory numbers
				//mixin(trace("/* before */ _adds")); // []
				_adds = arrayCatNumbers(input);
				//mixin(trace("/* after arrayCatNumbers(input); */ _adds")); // [1]
				foreach(add; _adds) {
					_taskMan ~= new Task(
						_dateTime,
						add,
						_taskMan.getPossibleTask(cast(uint)add).taskString // get string using id
					);
					_taskMan.setTaskIndex(cast(immutable int)_taskMan.numberOfTasks - 1);
					_selectNumbers ~= cast(int)_taskMan.numberOfTasks - 1;
				}
			}
		} else {
			_selectNumbers = selection;
		}

		string result = "\n";
		//mixin(trace("_selectNumbers.length"));
		foreach(select; _selectNumbers) {
			//mixin(trace("select"));
			_taskMan.setTaskIndex(cast(immutable int)select);

			immutable commands = cast(immutable)separateCommands(cast(immutable)input);

			foreach(seg; separateCommands(input)) { // loop task ---
				_command = getType(seg);
				_parameterString = getString(_command, seg);
				if (_command == "st" || _command == "et" || _command == "sd" || _command == "l") {
					try {
						_parameterNumbers = _parameterString.split.to!(int[]);
					} catch(Exception e) {
						import std.stdio: writeln;
						import std.conv: text;

						immutable error = text("Error with: [", _parameterString, "]");
						error.writeln;
						result ~= error ~ "\n";

						return result;
					}
				}
				
				result ~= doCommand();
			}
		}

		//#I don't know what's supposed to happen here
		enum stillJustNewLine = "\n";
		if (result == stillJustNewLine) {
			std.file.append("inputlog.txt", input ~ "\n");

			result ~= setUp(input);
		}

		return result;
	} // processInput

	string setUp(ref string input) {
		//bool isNumbercs = _adds.length > 0; // is it bool isNumber = false; isNumbercs - isNumber(s)
		
		bool notDigit(char c) {
			return ! std.ascii.isDigit(c);
		}
		
		/+
				 + This is what this is for:
				 + 
				 + Check each id number value is in bounds
				 + 
				 + then add a new task for each with the default settings (date, id, 
				 +/

		/+
		if (_adds.length > 0) {
			foreach(taskId; _adds) { //#here
				if (! (taskId >= 0 && taskId < _taskMan.getNumberOfPossibleTasks)) // check if valid number
					writeln(taskId," is an invalid catergory id."); // warning to user
				else {
					_taskMan ~= new Task( // add new task
					                     _dateTime,
					                     taskId,
					                     _taskMan.getPossibleTask(cast(uint)taskId).taskString // get string using id
					                     );
					_taskMan.viewLast;
					_taskMan.setTaskIndex(cast(int)_taskMan.numberOfTasks - 1);
				}
			}
			_adds.length = 0;
		}
		+/

		if (input.length > 1) {
			string type = getType( input );
			_parameterString = getString( type, input );
			//_parameterString = getString2(input );
			_parameterNumbers = getNums( type, input );
		}
		
		bool ifNotInListOfcommands(in string a, in string list2D) immutable pure nothrow {
			auto list = list2D.split(" ");
			foreach(item; list)
				if (a == item)
					return false; // it is in the list
			
			return true;
		}
		
		// Note look above as well for input
		
		immutable extra = 1;
		for(int i=0; i < _recNums.length + extra; i++) {
			int recNum;
			if (i < _recNums.length) // if not extra
				recNum = _recNums[i];
			
			immutable type = getType(input);
			
			if (ifNotInListOfcommands(type, "sd st et l c")) // if v p etc then don't do more than one //#what?
				break;
		} // Foreach

		//_command = input; //getType(input);
		_command = getType(input);
		_parameterString = getString(_command, input);
		//mixin(traceLine("input _command _type _parameterString".split));

		return doCommand();
	} // setUp

	/// Find the end of the type in input, looking for a number or a quote
	string getType(string input)
	{
		bool hit(char c) {
			import std.algorithm: canFind;

			//return c.inPattern(std.ascii.digits ~ '"');
			return (std.ascii.digits ~ '"').canFind(c);
		}
		
		foreach(i, c; input)
			if (true == hit(c)) // eg lt50 -> 'lt' or et"1 2 3" -> et or v -> 'v'
				return _type = input[ 0 .. i];

		return input; // no type //#why not '""' - because it might be 'v' for example
	}
	
	/// check just numbers in the passed string
	bool isDigits(in string operand)
	{
		import std.algorithm: canFind;

		// go through operand checking for a non digit
		foreach( check; operand )
			//#not sure about the '~ " "' maybe put a optional parameter to this function
			//if (false == check.inPattern(std.ascii.digits ~ " ") )
			if (false == (std.ascii.digits ~ " ").canFind(check))
				return false; // not all numbers
		return true; // all numbers
	}  
	
	/// Process user input: Get number or array
	int[] getNums(in string start, string input) {
		if (input.length > start.length) {
			try {
				if (input[start.length] == '"')
					return input[start.length + 1 .. $ - 1].split(" ").to!(int[]);
				else
					return input[start.length .. $].split(" ").to!(int[]);
			} catch(Exception e) {
			}
		} // if input
		return [];
	}
	
	/// Process user input: for eg. 'c"just a short distance."' gets the part between the quotes
	string getString(in string start, in string input)
	{
		if (input.length <= start.length + 2 || // if workable length
		    input[start.length] != '"') // || input[ $ - 1 ] != '"' ) // if got the quotes, and have quotes right at the end
			return "";
		return input[ start.length + 1 .. input[ $ - 1 ] == '"' ? $ - 1 : $ ];
	}


	unittest {
		Control c;
		import std.range;
		writeln("-".replicate(10));

		writeln("getString ?");
		immutable input = `st"1 2 3"`;
		immutable start = c.getType(input);
		with(c)
			writeln('[', getString(start, input), ']');
	}

	//#crashes with numbers
	string getString2(in string input) {
		long start, end;
		while(start < input.length && input[start] != '"')
			start++;
		end = input.length - 1;
		while(end > 0 && input[end] != '"')
			end--;

		//return input[start+1 .. end-1];
		return input[start+1 .. end];
	}

	void testMisc() {
		import std.range;
		writeln('-'.repeat.take(10));
		
		Control c;
		//TaskMan t;
		writeln("getString2");
		with(c)
			writeln('[', getString2(`st"1 2 3"`), ']'); //,
		//	run(t);
	}

	unittest {
		import std.range;
		writeln('-'.repeat.take(10));

		Control c;
		//TaskMan t;
		writeln("getString2");
		with(c)
			writeln('[', getString2(`st"1 2 3"`), ']'); //,
		//	run(t);
	}

	//#E.g. if you miss c for comment ("got up") it just ignores it, it should abort
	auto processCommandsFromTextFile() {
		string result;
		/*
		line = `1 2 3 c"one two three" st"4 5 6"` ->

		seg[0] = `c"one two three"`
		seg[1] = `st"4 5 6"`
			*/
		import std.ascii: isDigit;
		string[] lines;
		immutable textFile = _parameterString.setExtension(".txt");

		//writeln("---\n" ~ readText(textFile) ~ "\n---");

		if (! textFile.exists) {
			result = "File did not found '" ~ textFile ~ "'";
		} else {
			_autoInput.length = 0;
			foreach(char[] commandFrmFileLine; File(textFile, "r").byLine()) { // more of a proper test, can keep adding it self to the document
				if (commandFrmFileLine.length > 0) {
					auto line = commandFrmFileLine.idup.strip ~ ' ';
					if (commandFrmFileLine[0].isDigit)
						lines ~= line;
					else
						lines[$-1] ~= line;
					import std.string: strip;

					if (line.strip.length > 0)
						result ~= line ~ "\n";
				}
				//foreach(i, seg; separateCommands(commandFrmFileLine.idup)) {
				//	_autoInput ~= AutoInput(commandFrmFileLine.idup, seg, i == 0 ? true : false);
				//}
			} // thumbs up!
			//writeln([lines]); //#put this in

			int count;
			abort0: foreach(line; lines) { // loop each line ---
				//mixin(trace("count++"));

				//#here
				_adds = arrayCatNumbers(line); // _add = #(s) and remove
				//mixin(trace("line"));

				//mixin(trace("_adds"));
				int countAdd;

				foreach(add; _adds) { // loop numbers ---
					//mixin(trace("countAdd++"));

					/+
					with(_taskMan.getTask(cast(int)_taskMan.doneTasks)) { // add eg equals 90 for jokes
						mixin(traceLine("cast(int)_taskMan.doneTasks-1, add, taskString, timeLength, comment, dateTime, displayTimeFlag, endTime, displayEndTimeFlag".split(", ")));
						_taskMan ~= new Task(add, taskString, timeLength, comment, dateTime, displayTimeFlag, endTime, displayEndTimeFlag); // add new task
					}
					+/

					_taskMan ~= new Task(
						_dateTime,
						add,
						//_taskMan.getTask(cast(immutable int)_taskMan.numberOfTasks - 1).taskString() //,
						//""
						_taskMan.getPossibleTask(cast(uint)add).taskString // get string using id
					);
					_taskMan.setTaskIndex(cast(immutable int)_taskMan.numberOfTasks - 1);

					foreach(seg; separateCommands(line)) { // loop task ---
						_command = getType(seg);
						_parameterString = getString(_command, seg);
						//mixin(trace("_parameterString"));
						import std.algorithm: startsWith;
						
						//_parameterNumbers = [0,0,0];
						//if (_command == "st" || _command == "et" || _command == "sd" || _command == "l")
						if (_command.startsWith("st", "et", "sd", "l"))
							_parameterNumbers = _parameterString.split.to!(int[]);
						else if (! _command.startsWith("c")) {
							result ~= line ~ "\n";
							result ~= "[" ~ _command ~ "] - Error! Aborting.. Check the code..";

							break abort0;
						}

						//categoryString(add);

						if (_command != "fc" && _command != "fileComands") {
							immutable command = doCommand();
							import std.conv: text;
							import std.string: strip;

							//if (command.strip.length > 0)
							//	result ~= command ~ "\n"; // uses _command
							//else
							result ~= text("Command: [", command, "], Id: ", cast(immutable int)_taskMan.numberOfTasks - 1, ", Add: ", add, ", Seg: [", seg, "], String, (", _parameterString, "), Numbers: ", _parameterNumbers, "\n");
						}
						/+
						with(_taskMan.getTask(add)) { // add eg equals 90 for jokes
							mixin(traceLine("cast(int)_taskMan.doneTasks-1, add, taskString, timeLength, comment, dateTime, displayTimeFlag, endTime, displayEndTimeFlag".split(", ")));
						}
						+/

						//_recNum = cast(int)_taskMan.doneTasks-1;

						//mixin(traceLine("_command _parameterString".split));
						//_recNum = cast(int)_taskMan.doneTasks-1;
						//_autoInput ~= AutoInput(seg);
						//mixin(trace("seg"));

						//	this( int  id0, string taskString0, TimeLength length0, string comment0, DateTime dateTime0, bool displayTimeFlag0, DateTime endTime0, bool displayEndTimeFlag0 )
					} // separateCommands(line)
				} // _adds
			} // lines
//					version(none) {
				_autoInputPos = 0; // set postion to start segment
//						_inputType = InputType.autoInput;
//						
				_autoLines = lines;
//					}
		}

		/*
		import std.range;
		writeln('-'.repeat.take(10));
		foreach(line; lines)
			writeln(line);
		*/
		_done = true;

		return result;
	} // processCommandsFromTextFile

	/// do command eg. st"20 53 0"
	string doCommand() {
		string result = _command;

		//writeln("Command Count: ", _commandCount++);
		//_taskMan.setTaskIndex(_recNum);
		switch(_command) {
			case "h", "help":
				result ~= "\nq/quit/exit - To quit" ~ "\n" ~
						"h/help - For this help" ~ "\n" ~
						"v - List tasks to choose" ~ "\n" ~
						"p - Print tasks done" ~ "\n" ~
						"t - Current date and time" ~ "\n" ~
						"# - add task to done tasks list" ~ "\n" ~
						"clearalltasks - Clear all done tasks" ~ "\n" ~
						`c"<text>" - add comment to selected task` ~ "\n" ~
						"s# - Select task to edit" ~ "\n" ~
						`sv/sv"<file name>" - Save` ~ "\n" ~
						`ld/ld"<file name>" - Load` ~ "\n" ~
						`sd"# # #" - set date. day month and year` ~ "\n" ~
						`st"# # #" - set start time: hour, minute, second respectively` ~ "\n" ~
						`et"# # #" - set end time: hour, minute, second respectively` ~ "\n" ~
						`l"# # #" - set time length (hours, minutes, and seconds)` ~ "\n" ~
						"lt# - List by type" ~ "\n" ~
				        `printDay/pd"# # # (# # #)" - view a day or range` ~ "\n" ~
						`d"<file name>" - Dump to text file` ~ "\n" ~
						"*r# - remove task with by number" ~ "\n" ~
						"sort - sort list by time" ~ "\n" ~
						`*addCategory/ac"<name>"` ~ "\n" ~
						"*hideCategory/hc#" ~ "\n" ~
						"*revealCategory/rc#" ~ "\n" ~
						"showHiddenCategorys/shc - show all hidden categorys." ~ "\n" ~
						`fileComands/fc"<file name>" - from file commands (don't add ext), Note: save first` ~ "\n" ~
						"TaskDate/td - Show current date" ~ "\n" ~
						`calculate/ct"# # # -/+ # # #" - calculate time between two times` ~ "\n" ~
						`*listCatogories/lc - list each for handy format`~"\n" ~
						`*convertToCommands/ctc <name> - Convert a copy of the data back to commands version.` ~ "\n"~
						`customFormatList/cfl - Set the format for displaying the tasks.`~"\n"~
						`showFormatTags/sft - show format tags for custom format list` ~ "\n" ~
						"cls - clear the screen and text tank" ~ "\n" ~
						"vtt - view text tank" ~ "\n" ~
						`stt"<file name>" - save tank text` ~ "\n" ~
				        `sp"<phrase>" - search text`;
			break;
			case "fileComands", "fc":
				result ~= "\n" ~ processCommandsFromTextFile();
			break;
			case "printDay", "pd":
				if (_parameterNumbers.length == 3) {
						result = _taskMan.printDay(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
				} else if (_parameterNumbers.length == 6) {
						result = _taskMan.printDay(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2],
										  _parameterNumbers[3], _parameterNumbers[4], _parameterNumbers[5]);
				} else {
					result ~= "Error with printing a day or range of days";
				}
				break;
			//case "stswitch", "stw": 

			//	break;
			case "st":
				if (_parameterNumbers.length == 3) {
					scope( success ) {
						//writeln( timeString( DateTime( _dateTime.year, _dateTime.month, _dateTime.day,
						 //                            _parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2] ), /+ second: +/ true ) );
						
						//_time = DateTime(_dateTime.year, _dateTime.month, _dateTime.day
						//                , _parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
					}
					try {
						result ~= _taskMan.setTime(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
						//result = 
					} catch( Exception e ) {
						//writecln( Color.red, "Invalid time, try once more." );
						result ~= "Invalid start time, try once more.";
					}
				}
				break;
			case "et":
				if (_parameterNumbers.length == 3) {
					scope( success ) {
						//writeln( timeString( DateTime( _dateTime.year, _dateTime.month, _dateTime.day,
						 //                             _parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2] ), /+ second: +/ true ) );
						
						//_endTime = DateTime(1,1,1 //_dateTime.year, _dateTime.month, _dateTime.day
						//                    , _parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
					}
					try {
						result ~= _taskMan.setEndTime(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
					} catch( Exception e ) {
						//writecln( Color.red, "Invalid time, try once more." );
						result ~= "Invalid end time, try once more.";
					}
				}
				break;
				case "l":
					if ( _parameterNumbers.length == 3 ) {
						result ~= _taskMan.setTimeLength(TimeLength(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]));
					//writeln("length of time: ", [_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]]);
					}
					else {
						//writecln( Color.red, "Wrong number of operants(sp), try once more." );
						result ~= "Wrong number of operants(sp) for length of time, try once more.";
					}
				break;
				//#can terminate, must fix!
				// Set date eg. 'sd"23 10 2010"'
			case "sd":
				if ( _parameterNumbers.length == 3 ) {
//					if (! (_parameterNumbers[0] > 0 && _parameterNumbers[0] <= 31
					if (! (_parameterNumbers[0] > 0 &&
						_parameterNumbers[0] <= (DateTime(Date(_parameterNumbers[2], _parameterNumbers[1], 1), TimeOfDay(0, 0, 0)).daysInMonth)
					&& _parameterNumbers[1] >= 1 && _parameterNumbers[1] <= 12)) {
						result ~= "Error! Date not set with date time";
						break;
					}
					
					//#was bug here, still a bug on Lukes version
					scope(success) {
						immutable tex = format("Date set: %s.%02s.%s",
						         _parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]); // date, month, year;
						writefln(tex);
						result ~= tex;
						_dateTime = DateTime(_parameterNumbers[2], _parameterNumbers[1], _parameterNumbers[0]
						, _dateTime.hour, _dateTime.minute, _dateTime.second);
					}
					try {
						_taskMan.setDate(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
					} catch(Error e) {
						//writecln( Color.red, "Invalid date, try once more." );
						result ~= "Invalid date, try once more.";
					}
				}
				else {
					//writecln( Color.red, "Wrong number of arguments (just day, month, and year.)" );
					result ~= "Wrong number of arguments (just day, month, and year.) - date";
				}
				break;
			case "c":
				mixin(trace("_parameterString"));
				_taskMan.setComment( _parameterString );
				break;
				//#new
			case "sp":
				if ( _parameterString != "" ) {
					result ~= _taskMan.listFoundText(_parameterString);
					_command = "";
				} else {
					result ~= "This is not possible.";
				}
				break;
			case "stt":
				auto fileName = "tankText";
				if ( _parameterString != "" ) {
					fileName = _parameterString;
				}
				_taskMan.saveTextTank(fileName.setExtension(".txt"));
			break;
			case "cls":
				_taskMan.textTank = "";
				result ~= "Text tank clear";
			break;
			case "vtt":
				result ~= _taskMan.textTank;
			break;
			case "showFormatTags", "sft":
				//#need st and et
				result ~= "\nFormat tags:\n" ~
				"* - ?\n" ~
				"%nl - new line\n" ~
				"%cn - category number\n" ~
				"%cl - category label\n" ~
				"%dd - date day\n" ~
				"%wd - whole date\n" ~
				"%co - comment\n" ~
				"%in - item number\n" ~
				"*%st - start time\n" ~
				"*%et - end time\n" ~
				"*%sn - select number";
			break;
			case "customFormatList","cfl":
				if ( _parameterString != "" ) {
					_taskMan.customFormatList(_parameterString);
				}
			break;
			case "convertToCommands","ctc":
				string fileName = "toCommands";
				if ( _parameterString != "" ) {
					fileName = _parameterString;
				}
				_taskMan.convertToCommands(fileName.setExtension(".txt"));
			break;
			case "listCatogories", "lc":
				result ~= _taskMan.view(TaskType.possibles, 1);
			break;
			case "calculate", "ct":
				scope(failure)
					writeln("Some failure.");
				auto params = _parameterString.split();
				if (params.length != 7) {
					writeln(params.length, " is a wrong number of parameters in this case.");
					break;
				}
				if (params[3] == "-") {
					auto tod = TimeOfDay(params[0].to!int(), params[1].to!int(), params[2].to!int())
						- TimeOfDay(params[4].to!int(), params[5].to!int(), params[6].to!int());
					writeln("- ", tod.toString());
					result ~= text("- ", tod.toString());
				} else if (params[3] == "+") {
					
					enum {hour,minute,second, hours=4,minutes,seconds}

					int p(int num)() { return params[num].to!int(); } //#tricky

					auto t = TimeOfDay(p!hour, p!minute, p!second);

					t += dur!"hours"(p!hours) + dur!"minutes"(p!minutes) + dur!"seconds"(p!seconds);

					writefln("+ %s:%02s:%02s",
							 t.hour, t.minute, t.second);
					result ~= text("\n+ %s:%02s:%02s",
							 t.hour, t.minute, t.second);
				}
			break;
			case "skip":
				// move along
			break;
			case "TaskDate", "td":
				with(_dateTime)
				{
					writefln(
						"%s.%02s.%s ", // date, month, year
						day, cast(int)month, year);
					result ~= text("\n",
						"%s.%02s.%s ", // date, month, year
						day, cast(int)month, year);
				}
			break;
			case "sort":
				writeln( "Sorting...please wait..." );
				_taskMan.doSort;
				writeln( "Sorting done." );
				result ~= "\nSorting done.";
				break;
			case "d":
				if ( _parameterString != "") {
					_taskMan.saveToTextFile( _parameterString.setExtension(".txt") ); // ~ ".txt" );
					writeln( "Saved to text file." );
					result ~= "\nSaved to: " ~ _parameterString.setExtension(".txt");
				} else {
					//writecln( Color.red, "Needs a file name" );
					writeln( "Needs a file name" );
					result ~= "\nNeeds a file name";
				}
			break;
			case "t":
			//#looks similer to base.timeString(DateTime time, bool includeSecond = false) function
				// timeString(cast(DateTime)Clock.currTime, true); //#but doesn't have the day of the week, and different layout
				DateTime dateTime = cast(DateTime)Clock.currTime();
				with(dateTime)
				{
					writefln(
						"%s " ~ // day of the week (eg. 'Saturday')
						"%s.%02s.%s " ~ // date, month, year
						"[%s:%02s:%02s%s]", // hour:minute:second am/pm
						//split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday Someday")[dayOfWeek],
						split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday")[dayOfWeek],
						day, cast(int)month, year,
						hour == 0 || hour == 12 ? 12 : hour % 12, minute, second, hour <= 11 ? "am" : "pm");

					result ~= format("\n%s " ~ // day of the week (eg. 'Saturday')
						"%s.%02s.%s " ~ // date, month, year
						"[%s:%02s:%02s%s]", // hour:minute:second am/pm
						//split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday Someday")[dayOfWeek],
						split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday")[dayOfWeek],
						day, cast(int)month, year,
						hour == 0 || hour == 12 ? 12 : hour % 12, minute, second, hour <= 11 ? "am" : "pm");
				}
			break;
			// list the entries of selected type
			case "lt":
				if ( _parameterNumbers.length == 1 )
				{
					result ~= _taskMan.listByType( _parameterNumbers[0], _taskMan.cformat );
				}
			break;
			// Remove task
			//#need to be able to do like this - eg. `r"0 1 2"` to wipe three off
			case "r":
				if ( _parameterNumbers.length == 1 ) {
					/+
					import std.ascii: toLower;
					writeln("Are you sure (y/n)?");
					auto option = readln().chomp;
					if (option.length) {
						switch(option[0].toLower()) {
							case 'y':
					+/
								_taskMan.removeAt( _parameterNumbers[0] );
					/+
								break;
							default:
								break;
						}
					}
					+/
				}
				break;
			// This works, but only one 
			case "s": //#more work, maybe put view instead
				// select task to use
				if ( _parameterNumbers.length == 1 )
				{
					_taskMan.setTaskIndex( _parameterNumbers[0] );
					_recNums.length = 0;
					_recNums ~= _parameterNumbers[0];
					auto task() {
						return _taskMan.getTask(_parameterNumbers[0]);
					}
					with(task) {
						writeln( "Selected: ", _parameterNumbers[0], " - ",
							id, " ",
							dateTime.day, ".",
							dateTime.month.to!string[0 .. 1].toUpper, dateTime.month.to!string[1 .. $], ".",
							dateTime.year, " ",
							taskString(), " ",
							comment);
						result ~= text("\nSelected: ", _parameterNumbers[0], " - ",
							id, " ",
							dateTime.day, ".",
							dateTime.month.to!string[0 .. 1].toUpper, dateTime.month.to!string[1 .. $], ".",
							dateTime.year, " ",
							taskString(), " ",
							comment);
					}
					//_selected = true;
					_selectNumbers.length = 0;
				} else {
					writeln("Error, eg 's1600'");
				}
			break;
			case "v":
				result ~= "\n" ~ _taskMan.view(TaskType.possibles);
				break;
			case "p":
				result ~= "\n" ~ _taskMan.view( TaskType.done );
				break;
			case "pall":
				result ~= "\n" ~ _taskMan.view( TaskType.allDone );
			break;
			case "q", "quit", "exit":
				_done = true;
				return ""; //#comes up with a warning about break being not reachable
			//break;
			case "sv":
				if ( _parameterString != "" ) // eg. sv"back"
				{
					_taskMan.saveDoneTasks( _parameterString ~ ".bin" );
					result ~= "\n" ~ _parameterString ~ ".bin";
				}
				else
				{
					//writeln( "You may not save at this point in time!" );
					_taskMan.saveDoneTasks( "tasklog.bin" );
					result~= "\ntasklog.bin";
				}
			break;
			case "clearalltasks":
				_taskMan.clearDoneTasks;
			break;
			case "ld":
				// Is it not the default
				if ( _parameterString != "" ) // eg. ld"back"
				{
					_taskMan.loadDoneTasks( _parameterString ~ ".bin" );
					result ~= "\n" ~ _parameterString ~ ".bin" ~ " loaded.";
				}
				else // it is the default
				{
					_taskMan.loadDoneTasks("tasklog.bin");
					result~= "\ntasklog.bin loaded.";
				}
			break;
			//#new
			case "addCategory", "ac":
				if ( _parameterString != "" ) {
					import std.file;
					append("taskpossibles.txt", format("\n%03d %s", _taskMan.getNumberOfPossibleTasks(), _parameterString)); //#untested 19 Aug 2013
					processCategory(_taskMan);
					writeln("New Category added");
				} else {
					writeln("Some thing is a miss.");
				}
			break;
			case "hideCategory", "hc":
				if (_parameterNumbers.length == 1) {
					import std.file;
					append("taskshidden.txt",
						format("\n%03s %s", _parameterNumbers[0], _taskMan.getPossibleTask(_parameterNumbers[0]).taskString));
					processCategory(_taskMan);
					tasksHidden(_taskMan);
					writeln("Category hidden: ", format("\n%03s %s", _parameterNumbers[0], _taskMan.getPossibleTask(_parameterNumbers[0]).taskString));
				}
			break;
			case "revealCategory", "rc":
				if (_parameterNumbers.length == 1) {
					tasksHidden(_taskMan, /* remove */ _parameterNumbers[0]);
					processCategory(_taskMan);
					writeln("Done. use 'v' to see change");
				} else {
					writeln("No go.");
				}
			break;
			case "showHiddenCategorys", "shc":
				result ~= _taskMan.showHiddenCategorys();
			break;
			default:
				//debug
				if (! _isNumber && _command != "")
					writeln('[', _command, ']', " command is unreconized.");
			break;
		} // switch
		_command = ""; //#a hack - calls doCommand twice! but I can't see 2 calls

		return result;
	} // do command

	/*
					Title: Check if setting(s) are valid - unused as of yet
					
				*/
	// probably remove this validSettings inner function, not using it
	// [key label] [number or array]
	// length      "0 5 0" - get length in time
	// s           409 - select activity
	/*
				Method:
				start with input
				check to if it's got data (egs. 'l"0 5 0"' or 's409' or not 'v')
				*/
	bool validSettings(in string input, in string type, in int args)
	{
		if (input == "" || input.length <= type.length || input[ 0 .. type.length ] != type ) // 's' or 'l""'
			return false;
		bool quote = ( input[ type.length ] == '"' );
		if ( args == 1 && ! quote ) // if one argument (eg. 's215')
		{
			return isDigits( input[ type.length .. $ ] ); // check if all numbers
		}
		else // if not one argument (eg. 'l"0 5 0"')
		{
			// has the least workable
			if ( input.length <= type.length + 3 && input[ type.length ] == '"' && input[ $ - 1 ] == '"' )
			{
				auto operands = split( input[type.length + 1 .. $ - 1] );
				if ( operands.length != args )
					return false; // wrong number of arguments
				foreach ( number; operands )
					if ( ! isDigits( number ) )
						return false; // contains a non number
				return true; // valid operands
			}
		}
		return false;
	} // test for if valid input

	unittest {
		import std.range;
		writeln("-".replicate(10));

		Control c;
		TaskMan t;

		with(c) {
			//string[] separateCommands(string line) {
			string input = `1 st"10 30 0" c"one"`;
			writeln(q{input = `1 st"10 30 0" c"one"`});
			//mixin(jecho(q{string input = `1 st"10 30 0" c"one"`})); //#not work eg Error: found '10' when expecting ',' etc
			auto segments = separateCommands(input);

			immutable type = getType(segments[1]);
			import std.string: split;
			mixin(traceLine("type segments".split));
		    //doCommand(recNum, type, _parameterNumbers, parameterString, isNumbercs, done);
		}

	}
}
