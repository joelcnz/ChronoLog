//#crashes
//#there's another double notes character, to do as well
//#includes days
//#new (l"1,2,3" wasn't working - had to be space seperated) 6 9 2018
//#may change it to 'ErroR:' and edit all the connected stuff
//#Why didn't this trigger when I tested it?!
//#untested 11 2 2018 - this is need for parsing commandfile.txt
//#process text file not supported any more
//#need better than startWith
//#don't understand set up here
//#I got a crash, I don't know how?!
//#shouldn't need try..catch
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

//	import arsd.terminal;
//	import dunit;
	import jmisc;
	import jtask.basebb;
	import base, gui, taskman, task; // main
}

//immutable jechoState = false;

version(unittest) {
//	void main() {}
}

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
	string _helpTxt;

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

	/++
	 + In `1 2 3 c"test"` - return [1, 2, 3]
	 	and change string to ` c"test`
	 +/
	//Note has to have a number or space at the start
	int[] arrayCatNumbers(/* cut the numbers off the start */ ref string line) {
		import std.algorithm : countUntil;
		import std.conv : to;
		import std.string : split;

		int[] nums;
		//#shouldn't need try..catch
		try {
			// collect just numbers and spaces from the start and stop if any thing else
			size_t p = line.countUntil!(cs => cs.isAlpha);

			if (p >= line.length)
				p = line.length;
			immutable strNums = prepareNumsFromStr(line[0 .. p]);
			line = line[p .. $];
			nums = strNums.split.to!(int[]);
		} catch(Exception e) {
			writeln("Whoops..");
		}

		return nums;
	} // arrayCatNumbers

	unittest {
		Control t;
		string s;
		s = "1 2 3"; assert(t.arrayCatNumbers(s) == [1,2,3]);
		s = "1 b c"; assert(t.arrayCatNumbers(s) == [1]); writeln(s); assert(s == "b c");
		s = "a b c"; assert(t.arrayCatNumbers(s) == []); assert(s == "a b c");
		s = "a 2 3"; assert(t.arrayCatNumbers(s) == []); assert(s == "a 2 3");
	}
public:
	@property ref TaskMan taskMan() { return _taskMan; }

	void setup(TaskMan taskMan) {
		import std.file: readText;

		_dateTime = cast(DateTime)Clock.currTime();

		_helpTxt = readText("helpTxt.txt");

		_taskMan = taskMan;
		_taskMan.loadDoneTasks("tasklog.bin");

		_taskMan.resetViewTasks;
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
					} else {
						result ~= line[st .. ed]; // superceeded(sp)
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
			final switch(sw) with(Switch) {
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

	unittest {
		Control c;
		writeln('[', c.separateCommands("rng1"), ']');
		writeln('[', c.separateCommands("rng-1"), ']');
		//assert(c.separateCommands("rng-1") == ["rng-1"]);
	}

	auto processInput(string input, int[] selection = []) {
		//#Maybe add task entries here for list or 1 id
		std.file.append("errorlog.txt", input ~ "\n");
		string result = "\n";
		import std.string : strip;

		input = input.strip;

		if (selection.length == 0) {
			_selectNumbers.length = 0;
			// if the input starts as a digit
			if (input.length > 0 && input[0].isDigit) { //#only catergory numbers
				_adds = arrayCatNumbers(/* ref */ input);
				foreach(add; _adds) {
					if (add < 0 || add >= _taskMan.getNumberOfPossibleTasks) {
						result ~= "Warning: (" ~ add.to!string ~ ") is out of bounds.";
						continue;
					}
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

		foreach(select; _selectNumbers) {
			_taskMan.setTaskIndex(cast(immutable int)select);
			_taskMan.clearStEdL;

			foreach(seg; separateCommands(input)) { // loop task ---
				_command = getType(seg);
				_parameterString = getString(_command, seg);
				import std.algorithm: startsWith;

				if (_command.startsWith("sd", "st", "et", "l")) {
					_parameterString = prepareNumsFromStr(_parameterString);
					_parameterString = for3Nums(_parameterString);
					try {
						_parameterNumbers = _parameterString.split.to!(int[3]);
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

	//#don't understand set up here
	string setUp(ref string input) {
		if (input.length > 1) {
			string type = getType( input );
			_parameterString = getString( type, input );
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
		} // for loop

		_command = getType(input);
		_parameterString = getString(_command, input);

		return doCommand();
	} // setUp

	unittest {
		Control c;
		string t = "rng-1";
		jecho(c.setUp(t));
	}

	/// Find the end of the type in input, looking for a number or a quote
	string getType(string input) {
		foreach(i, c; input)
			if (true == (std.ascii.digits ~ `"`).canFind(c)) // eg lt50 -> 'lt' or et"1 2 3" -> et or v -> 'v'
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

	auto prepareNumsFromStr(in string source) {
		import std.string: replace, strip;

		string s;
		foreach(l; source)
			if (l.isDigit)
				s ~= l;
			else
				s ~= " ";
		s = s.strip;
		string last = "";
		do {
			last = s;			
			s = replace(s, "  ", " ");
		} while(s != last);

		return s;
	}

	unittest {
		Control c;
		assert(c.prepareNumsFromStr("1.2.3.4") == "1 2 3 4");
		assert(c.prepareNumsFromStr("    1   .2.  3   4  ") == "1 2 3 4");
	}

	auto for3Nums(string source) {
		try {
			//#new (l"1,2,3" wasn't working - had to be space seperated) 6 9 2018
			source = prepareNumsFromStr(source);
			source.split.to!(int[3]);
		} catch(Exception e) {
			return "0 0 0";
		}
		return source;
	}

	unittest {
		Control c;
		assert(c.for3Nums("1 2 3 4") == "0 0 0");
		assert(c.for3Nums("1 2 3") == "1 2 3");
	}

	//#E.g. if you miss c for comment ("got up") it just ignores it, it should abort
	auto processCommandsFromTextFileOrEditBox(in string sourceTxt = "") {
		string result;
		/*
		line = `1 2 3 c"one two three" st"4 5 6"` ->

		seg[0] = `c"one two three"`
		seg[1] = `st"4 5 6"`
		*/
		import std.algorithm : startsWith;
		import std.ascii : isDigit;

		string[] lines;
		if (sourceTxt.length) {
			string[] sourceLines;
			import std.string : replace;

			//#there's another double notes character, to do as well
			sourceLines = sourceTxt.replace("”", `"`).split("\n");

			_autoInput.length = 0;
			foreach(commandFrmFileLine; sourceLines) { // more of a proper test, can keep adding it self to the document
				if (commandFrmFileLine.length > 0) {
					auto line = commandFrmFileLine.strip;
					if (line[0].isDigit) {
						lines ~= line;
					} else {
						if (lines.length > 0) {
							lines[$ - 1] ~= " " ~ line; //#untested 11 2 2018 - this is need for parsing commandfile.txt
						} else {
							result ~= "Must have a category number at the first line of the stuff in the text box!"; //#Why didn't this trigger when I tested it?!

							return result;
						}
					}
				}
			}

			int count;
			abort0: foreach(line; lines) { // loop each line ---
				_adds = arrayCatNumbers(line); // _add = #(s) and remove
				int countAdd;

				result ~= "line: [" ~ line ~ "]"; 

				foreach(add; _adds) { // loop numbers ---
					if (add < 0 || add >= _taskMan.getNumberOfPossibleTasks) {
						result ~= "Error: (" ~ add.to!string ~ ") is out of bounds.";
						break abort0;
					}
					_taskMan ~= new Task(
						_dateTime,
						add,
						_taskMan.getPossibleTask(cast(uint)add).taskString // get string using id
					);
					_taskMan.setTaskIndex(cast(immutable int)_taskMan.numberOfTasks - 1);

					foreach(seg; separateCommands(line)) { // loop task ---
						result ~= "seg: (" ~ seg ~ ") ";
						_command = getType(seg);
						result ~= "_command = #1[" ~ _command ~ "]";
						_parameterString = getString(_command, seg);
						import std.algorithm: startsWith;
						
						if (_command.startsWith("sd", "st", "et", "l")) {
							_parameterString = prepareNumsFromStr(_parameterString);
							if (_parameterString.split.length != 3) {
								result ~= "\n[" ~ _parameterString ~ "] Wrong number of numbers!";
								break abort0;
							}
							_parameterString = for3Nums(_parameterString);
							try {
								_parameterNumbers = _parameterString.split.to!(int[]);
							} catch(Exception e) {
								result ~= "\n[" ~ _parameterString ~ "] Error converting to numbers!";
								break abort0;
							}
						} else if (! _command.startsWith("c")) {
							result ~= line ~ "\n";
							result ~= "[" ~ _command ~ "] - Error! Aborting.. Check the code..";

							break abort0;
						}

						if (sourceTxt != "" || _command.startsWith("fc", "fileComands")) { //#need better than startsWith
							immutable command = doCommand();

							import std.conv: text;
							import std.string: strip;

							result ~= text("Command return value: #2[", command, "], Id: ", cast(immutable int)_taskMan.numberOfTasks - 1,
								", Add: ", add, ", Seg: [", seg, "], String, (", _parameterString, "), Numbers: ", _parameterNumbers, "\n");

							if (command.canFind("Error:")) { //#may change it to 'ErroR:' and edit all the connected stuff
								writeln(command);
								result ~= "Error returned!";
								break abort0;
							}
						}
					} // separateCommands(line)
				} // _adds
			} // lines
			_autoInputPos = 0; // set postion to start segment
			_autoLines = lines;
		} else 
			result = "Nothing to process..";

		_done = true;

		return result;
	} // processCommandsFromTextFileOrEditBox

	unittest {
		Control c;
		
		with(c) {
			immutable script = q{13 st"1 2 3" c"Test"};
			script.writeln;
			//_taskMan = new TaskMan; //#need this for _taskMan of type taskman.TaskMan
			c.setup(_taskMan);
			c.processCommandsFromTextFileOrEditBox(script); //#crashes
		}
	}

	/// do command eg. st"20 53 0", h, or rng"-5 -1" etc.
	string doCommand() {
		string result = _command;

		switch(_command) {
			case "h", "help":
				result ~= _helpTxt;
			break;
			case "rng", "range":
				if (_parameterNumbers.length == 1 || _parameterNumbers.length == 2) {
					try {
						int rng1, rng2;

						rng1 = _parameterNumbers[0];
						if (_parameterNumbers.length == 2)
							rng2 = _parameterNumbers[1];
						else
							rng2 = rng1;

						void setConvertIfNeg(ref int num) {
							if (num < 0)
								num = cast(int)_taskMan.numberOfTasks - num * -1;
						}
						setConvertIfNeg(rng1);
						setConvertIfNeg(rng2);

						import std.algorithm : swap;

						if (rng1 > rng2)
							swap(rng1, rng2);
						if ([rng1, rng2].all!(n => n >= 0 && n < _taskMan.numberOfTasks))
							result = _taskMan.getRange(rng1, rng2);
						else
							result = "\nSomething amiss..";
					} catch(Exception e) {
						//#I got a crash, I don't know how?!
						result = "\nWhoops..";
					}
				} else {
					result = "\nSomething amiss..";
				}
			break;
			case "fileComands", "fc":
				result ~= "\n" ~ processCommandsFromTextFileOrEditBox();
			break;
			case "printDay", "pd": //#includes days
				if (_parameterNumbers.length == 3) {
						result = _taskMan.printDayOrDays(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
				} else if (_parameterNumbers.length == 6) {
						result = _taskMan.printDayOrDays(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2],
										  _parameterNumbers[3], _parameterNumbers[4], _parameterNumbers[5]);
				} else {
					result ~= "Error with printing a day or range of days";
				}
				break;
			case "st":
				if (_parameterNumbers.length == 3) {
					try {
						result ~= _taskMan.setTime(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
					} catch( Exception e ) {
						result ~= "Error: Invalid start time, try once more.";
					}
				}
				break;
			case "et":
				if (_parameterNumbers.length == 3) {
					try {
						result ~= _taskMan.setEndTime(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
					} catch( Exception e ) {
						result ~= "Error: Invalid end time, try once more.";
					}
				}
				break;
				case "l":
					if ( _parameterNumbers.length == 3 ) {
						result ~= _taskMan.setTimeLength(TimeLength(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]));
					}
					else {
						result ~= "Error: Wrong number of operants(sp) for length of time, try once more.";
					}
				break;
				// Set date eg. 'sd"23 10 2010"'
			case "sd":
				if ( _parameterNumbers.length == 3 ) {
					try {
						if (! (_parameterNumbers[0] > 0 &&
							_parameterNumbers[0] <= (DateTime(Date(_parameterNumbers[2], _parameterNumbers[1], 1), TimeOfDay(0, 0, 0)).daysInMonth)
						&& _parameterNumbers[1] >= 1 && _parameterNumbers[1] <= 12)) {
							result ~= "Error: Date not set with date time";
							break;
						}
					} catch(Exception e) {
						result ~= "Error: Date not set with date time.. Invalid date: " ~
							_parameterNumbers[0].to!string ~ "." ~
							_parameterNumbers[1].to!string ~ "." ~
							_parameterNumbers[2].to!string;
						break;
					}
					
					//#was bug here, still a bug on Lukes version
					scope(success) {
						immutable tex = format("Date set: %s.%02s.%s",
						         _parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]); // date, month, year;
						writefln(tex);
						result ~= tex;
						_dateTime = DateTime(_parameterNumbers[2], _parameterNumbers[1], _parameterNumbers[0],
						_dateTime.hour, _dateTime.minute, _dateTime.second);
					}
					try {
						_taskMan.setDate(_parameterNumbers[0], _parameterNumbers[1], _parameterNumbers[2]);
					} catch(Exception e) {
						result ~= "Error: Invalid date, try once more.";
					}
				}
				else {
					result ~= "Error: Wrong number of arguments (just day, month, and year.) - date";
				}
				break;
			case "c":
				mixin(trace("_parameterString"));
				result ~= _taskMan.setComment(_parameterString);
				break;
				//#new
			case "ws":
				if ( _parameterString != "" ) {
					result ~= _taskMan.listFoundText(_parameterString, true);
				} else {
					result ~= "This is not possible.";
				}
			break;
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
				"%st - start time\n" ~
				"%et - end time\n" ~ 
				"%tl - time length\n" ~
				"%sn - select number";
			break;
			case "customFormatList","cfl":
				_taskMan.customFormatList(_parameterString);
			break;
			case "convertToCommands","ctc":
				string fileName = "toCommands";
				if ( _parameterString != "" ) {
					fileName = _parameterString;
				}
				_taskMan.convertToCommands(fileName.setExtension(".txt"));
			break;
			case "listCatogories", "lc":
				result ~= "\n" ~ _taskMan.view(TaskType.possibles, 1);
			break;
			case "calculate", "ct":
				try {
					auto params = _parameterString.split();
					if (params.length != 7) {
						writeln(params.length, " is a wrong number of parameters in this case.");
						result ~= "Some thing wrong with your input";
						break;
					}
					if (params[3] == "-") {
						auto tod = TimeOfDay(params[0].to!int(), params[1].to!int(), params[2].to!int())
							- TimeOfDay(params[4].to!int(), params[5].to!int(), params[6].to!int());
						writeln("- ", tod.toString());
						result ~= text("- ", tod);
					} else if (params[3] == "+") {
						
						enum {hour,minute,second, hour2 = 4, minute2, second2}

						int p(int num)() { return params[num].to!int(); } //#tricky

						auto tod = TimeOfDay(p!hour, p!minute, p!second);
						tod += dur!"hours"(p!hour2) + dur!"minutes"(p!minute2) + dur!"seconds"(p!second2);

						immutable newTime = text("+ ", tod);
						writeln(newTime);
						result ~= newTime;
					}
				} catch(Exception e) {
					writeln("Some failure.");
					result ~= "Invalid input, or some thing.";
				}
			break;
			case "skip":
				// move along
			break;
			case "TaskDate", "td":
				with(_dateTime)
				{
					writefln(
						"%s.%02s.%s [%s:%0s:%0s]", // date, month, year, hour, minute, second
						day, cast(int)month, year, hour, minute, second);
					result ~= format("\n",
						"%s.%02s.%s [%s:%0s:%0s]", // date, month, year, hour, minute, second
						day, cast(int)month, year, hour, minute, second);
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
			case "t", "time":
			//#looks similer to base.timeString(DateTime time, bool includeSecond = false) function
				// timeString(cast(DateTime)Clock.currTime, true); //#but doesn't have the day of the week, and different layout
				auto dateTime = cast(DateTime)Clock.currTime();
				with(dateTime)
				{
					writefln(
						"%s " ~ // day of the week (eg. 'Saturday')
						"%s.%02s.%s " ~ // date, month, year
						"[%s:%02s:%02s%s] " ~ // hour:minute:second am/pm
						"(%s %s %s)",
						//split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday Someday")[dayOfWeek],
						split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday")[dayOfWeek],
						day, cast(int)month, year,
						hour == 0 || hour == 12 ? 12 : hour % 12, minute, second, hour <= 11 ? "am" : "pm",
						hour, minute, second);

					result ~= format("\n%s " ~ // day of the week (eg. 'Saturday')
						"%s.%02s.%s " ~ // date, month, year
						"[%s:%02s:%02s%s] " ~ // hour:minute:second am/pm
						"(%s %s %s)",
						//split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday Someday")[dayOfWeek],
						split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday")[dayOfWeek],
						day, cast(int)month, year,
						hour == 0 || hour == 12 ? 12 : hour % 12, minute, second, hour <= 11 ? "am" : "pm",
						hour, minute, second);
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
					_taskMan.removeAt( _parameterNumbers[0] );
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
			case "v","viewCategories":
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
			case "sv", "save":
				try {
					import std.file: copy;

					auto ifSave(in string fileNameRoot) {
						import std.file: exists;

						immutable checkFile = fileNameRoot ~ ".bin";
						if (checkFile.exists) {
							copy(checkFile, fileNameRoot ~ "BackUp.bin");

							return true;
						}

						return false;
					}
					bool oldExisted = false;
					if ( _parameterString != "" ) // eg. sv"back"
					{
						oldExisted = ifSave(_parameterString);
						_taskMan.saveDoneTasks(_parameterString ~ ".bin");
						result ~= "\nSaved as: " ~ _parameterString ~ ".bin" ~
							(oldExisted ? " - also copied the old one as " ~ _parameterString ~ "BackUp.bin" : "");
					}
					else
					{
						//writeln( "You may not save at this point in time!" );
						copy("tasklog.bin", "tasklogBackUp.bin");
						_taskMan.saveDoneTasks( "tasklog.bin" );
						result~= "\nSaved: tasklog.bin - also copied the old one as tasklogBackUp.bin";
					}
				} catch(Exception e) {
					result~= "\nSome thing wrong.";
				}
			break;
			case "clearalltasks":
				_taskMan.clearDoneTasks;
			break;
			case "ld", "load":
				// Is it not the default
				if ( _parameterString != "" ) // eg. ld"back"
				{
					_taskMan.saveDoneTasks( _parameterString ~ "Old.bin" );
					_taskMan.loadDoneTasks( _parameterString ~ ".bin" );
					result ~= "\n" ~ _parameterString ~ ".bin" ~
						" loaded. (" ~ _parameterString ~ "Old.bin" ~ ", saved first)";
				}
				else // it is the default
				{
					_taskMan.saveDoneTasks( "old.bin" );
					_taskMan.loadDoneTasks("tasklog.bin");
					result~= "\ntasklog.bin loaded, (old.bin, saved first)";
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
				if (! _isNumber && _command != "") {
					writeln('[', _command, ']', " command is unreconized.");
					result ~= text("\n", '-', _command, '-', " command is unreconized.");
				}
			break;
		} // switch
		_command = ""; //#a hack - calls doCommand twice! but I can't see 2 calls

		return result;
	} // do command

	unittest {
		import std.range;
		writeln("-".replicate(10));

		Control c;

		with(c) {
			//string[] separateCommands(string line) {
			string input = `1 st"10 30 0" c"one"`;
			writeln(q{input = `1 st"10 30 0" c"one"`});
			//mixin(jecho(q{string input = `1 st"10 30 0" c"one"`})); //#not work eg Error: found '10' when expecting ',' etc
			auto segments = separateCommands(input);

			immutable type1 = getType(segments[1]);
			immutable type2 = getType(segments[2]);
			import std.string: split;
			mixin(trace("type1 type2 segments".split));
		    //doCommand(recNum, type, _parameterNumbers, parameterString, isNumbercs, done);
		}
	}
}
