//#enter 'v'
//#the line of dashes is stink
//#not sure on this for usin with sorting
//#maybe 0, 0, 0 for the tod
//#load part here
//#Need a thing for user to turn it on and off
//#need time of day hide
//#little adjustments
//#was if (hour == 99 || second == 66)
//#what about day of week?
//#replace all this with a single number
//#what is time taken
//#what's this for?	

module task;

private
{
	import std.stdio;
	import core.stdc.stdio;
	import std.string;
	import std.array;
	import std.conv;
	//import std.c.time;
	//import std.date;
	import std.datetime;
	
	import jtask.taskmanbb, jtask.basebb;
//	import terminal;
	import base, jmisc;
}

class Task {
private:
	static bool _altColour; // alternate colours

	bool _tagged = false;

	int _id; // category
	string _taskString;
	string _comment;
	DateTime _dateTime; // day, month, year, time taken (note: user sets this variable) //#what is time taken
	DateTime _endTime;
	TimeLength _length;

	bool _displayTimeFlag;
	bool _displayEndTimeFlag;
public:
	DateTime getDateTimeForSort() {
		DateTime dt = _dateTime;

		if (_displayTimeFlag == false) {
			if (_displayEndTimeFlag == true) {
				dt = DateTime(Date(_dateTime.year, _dateTime.month, _dateTime.day),
							  TimeOfDay(_endTime.hour, _endTime.minute, _endTime.second));
			}
		}

		return dt;

//		return _dateTime;
	}
	
	/+
	auto tid() { return _id; }
	auto taskString() { return _taskString; }
	auto comment() { return _comment; }
	auto dateTime() { return _dateTime; }
	auto endTime() { return _endTime; }
	auto tLength() { return _length; }
	auto displayTimeFlag() { return _displayTimeFlag; }
	auto displayEndTimeFlag() { return _displayEndTimeFlag; }
	+/
	
	/// task constructor sets task with current date and time
	this(DateTime dateTime = DateTime(1979,1,1), int id = 0, string taskString = "")
	{
		_id = id;
		_taskString = taskString;
		_length = TimeLength(0,0,0); // is any way
		_comment = ""; // is any way
		//_dateTime = getCurrentTimeNDate; // code is clear enough on this mater I dear to think.
		//_dateTime = cast(DateTime)toLocalTime();
		_dateTime = dateTime; // cast(DateTime)Clock.currTime();
		if (dateTime == DateTime(1979,1,1)) {
			//_dateTime = cast(DateTime)Clock.currTime();
			_dateTime = DateTime(1979,1,1, 12,0,0);
		}
		//_dateTime.second = 0; //#was 66, but that's invalid these days
		
		_displayTimeFlag = false; //#Need a thing for user to turn it on and off
		_displayEndTimeFlag = false;
	}
	
	// setAll
	this(int id0, string taskString0, TimeLength length0, string comment0, DateTime dateTime0,
		  bool displayTimeFlag0, DateTime endTime0, bool displayEndTimeFlag0) {
		_id = id0;
		_taskString = taskString0;
		_length = length0;
		_comment = comment0;
		_dateTime = dateTime0;
		_displayTimeFlag = displayTimeFlag0;
		_endTime = endTime0;
		_displayEndTimeFlag = displayEndTimeFlag0;
	}
	
	@property int id() { return _id; } // getter
	@property string taskString() { return _taskString; } // getter
	@property TimeLength timeLength() { return _length; } // getter
	@property string comment() { return _comment; } // getter
	
	@property DateTime dateTime() { return _dateTime; } // getter
	@property bool displayTimeFlag() { return _displayTimeFlag; } // getter
	@property void displayTimeFlag(bool dtf) { _displayTimeFlag = dtf; } // ? setter
	
	@property DateTime endTime() { return _endTime; } // getter
	@property bool displayEndTimeFlag() { return _displayEndTimeFlag; } // getter //#valid time or not 2/2
	@property void displayEndTimeFlag(bool detf) { _displayEndTimeFlag = detf; } // ? setter

	void setDate(int day0, int month0, int year0 ) {
		try {
			with( _dateTime )
				_dateTime = DateTime(year0, month0, day0, hour, minute, second); //#maybe 0, 0, 0 for the tod
		} catch(Exception e) {
			throw new Exception("Some thing wrong!");
		}
	}
	
	string catagoryToCommand() {
		return _id.to!string();
	}
	
	string dateToCommand() {
		with(_dateTime)
			return format(`sd"%s %s %s"`, day, month.to!int, year);
	}
	
	string timeToCommand() {
		with(_dateTime)
			return format(`st"%s %s %s"`, hour, minute, second);
	}
	
	string endTimeToCommand() {
		with(_endTime)
			return format(`et"%s %s %s"`, hour, minute, second);
	}
	
	string lengthToCommand() {
		with(_length)
			return format(`l"%s %s %s"`, hours, minutes, seconds);
	}
	
	string commentToCommand() {
		string result = _comment;
		
		result = replace(result, `"`, "'"); // command must not contain double quotes

		return format(`c"%s"`, result);
	}

	void setTime(int hour0, int minute0, int second0) {
		with( _dateTime )
			_dateTime = DateTime( year, month, day, hour0, minute0, second0 );
		displayTimeFlag = true;
	}

	void setEndTime(int hour0, int minute0, int second0) {
		with( _endTime )
			_endTime = DateTime( 1, 1, 1, hour0, minute0, second0 );
		displayEndTimeFlag = true;
	}

	void setTimeLength( TimeLength tl )
	{
		_length = tl;
	}
	
	void setComment(string comment)
	{
		_comment = comment;
	}
	
	/// view the tasks infomation
	string viewInfo(int bullitNumber, int indexNumber, int collum, TaskType taskType = TaskType.possibles, string cformat = "" )
	{
		string result;
		final switch( taskType )
		{
			case TaskType.done:
			case TaskType.allDone:
				if (cformat == "") {
					//mixin(trace("_comment"));
					//writecln( _altColour == true ? Color.green : Color.yellow, doneString( indexNumber ) );
					//#the line of dashes is stink
					import std.range: repeat;
					import std.conv: to;
					result = doneString(bullitNumber, indexNumber) ~ "\n"; // ~ 
					//	"-----------------"
					result ~= '-'.repeat(20).to!string;
					result ~= "\n";

					//#crashes in Windows (when no output in the command line)
					version(OSX) {
						write(result); std.stdio.stdout.flush();
					}
					//writeln(doneString( indexNumber ));
					//writeln("----------------");
					//_altColour = ! _altColour;
				} else {
					result = doneString(bullitNumber, indexNumber, cformat);
					version(OSX) {
						write(result); std.stdio.stdout.flush();
					}
					//writeln(doneString(indexNumber, cformat));
				}
			break;
			//#enter 'v'
			case TaskType.possibles:
				writef(["%3s - %-33s%s", "%3s - %s%s"][collum], // id, possible task string
							id, taskString,
							collum == Collum.right ? "\n" : "" );
				result ~= format(["%3s - %-33s%s", "%3s - %s%s"][collum], id, taskString, collum == Collum.right ? "\n" : "");
			break;
		} // switch
		
		return result;
	}
	
	string doneString(int bullitNumber, int indexNumber, string cformat = "" )
	{
		if (cformat != "") {
			string result = cformat;
			foreach(tag; "%sn %in %nl %cn %cl %dd %wd %co %st %et %tl".split()) {
				string piece = "";

				switch(tag) {
					case "%sn":
						piece = indexNumber.to!string();
					break;
					case "%in":
						piece = bullitNumber.to!string();
					break;
					case "%nl":
						piece = "\n";
					break;
					case "%cn":
						piece = _id.to!string();
					break;
					case "%cl":
						piece = _taskString;
					break;
					case "%dd":
						piece = _dateTime.day.to!string();
					break;
					case "%wd":
						piece = getDateString();
					break;
					case "%co":
						piece = _comment;
					break;
					case "%st":
						if (displayTimeFlag())
							piece = timeString(_dateTime);
					break;
					case "%et":
						if (displayEndTimeFlag())
							piece = " -> " ~ timeString(_endTime);
					break;
					case "%tl":
						if (! (_length.hours == 0 && _length.minutes == 0 &&  _length.seconds == 0))
							piece = _length.toString;
					break;
					default:
					break;
				}

				if (piece)
					result = replace(result, tag, piece);
			}
			
			return result;
		} else {
			string timeLength;
			if ( _length.hours == 0 && _length.minutes == 0 &&  _length.seconds == 0 )
				timeLength = "";
			else
				timeLength = format( "%s", _length.toString );
			with (_dateTime)
			{
				string hourMinSecStr;
				if ( _displayTimeFlag == true )
					hourMinSecStr = format( "[%s:%02s.%02d%s]",
											(hour == 0 || hour == 12 ? 12 : hour % 12), 
											 minute,
											 second,
											(hour < 12 ? "am" : "pm") );
				else
					hourMinSecStr = "";
					
				string endHourMinSecStr;
				if (_displayEndTimeFlag)
					with(_endTime) {
						endHourMinSecStr = "-> " ~
												format( "[%s:%02s.%02d%s]",
												(hour == 0 || hour == 12 ? 12 : hour % 12), 
												 minute,
												 second,
												(hour < 12 ? "am" : "pm") );
					}

				return format("% 4s) %s - %s" ~ // index number, id, taskString
						" - %s," ~ // name of the week
						" %s.%s.%s" ~ // day, month, year
						" %s %s %s %s", // maybe time (hour minute, and am/pm), maybe time period, and maybe comment
						indexNumber, id, taskString,
						//split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday Someday")[weekday],
						split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday Someday")[ _dateTime.dayOfWeek ],
						day, month.to!string()[0..1].toUpper() ~ month.to!string()[1..$], year,
						hourMinSecStr, endHourMinSecStr, timeLength, // see above for formating of these strings
						_comment != "" ? format(`%s`, _comment) : "");
			}
		}
	}

	string getDateString() {
		with (_dateTime) {
			return format("%s.%s.%s", day, month.to!string()[0..1].toUpper() ~ month.to!string()[1..$], year);
		}
	}

	//#what's this for?	
	void toFile(FILE* file)
	{
	}	
	
	unittest
	{
		auto task = new Task;
		mixin(test("task !is null", "allocated"));
		mixin(test("task.id == 0", "id = 0"));
		destroy(task);
		mixin(test("task is null", "dallocate"));

	}
}
