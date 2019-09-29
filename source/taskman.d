//# %in - not setup right 4.5.2019

//#printDay (should be days)
//#sort
//#raw write?
//#how did the goto get here?
//#new
//#Possible tasks
//#cannot understand the next two resualts
//#don't know why it works
//#not try catch
//# set new done tasks
module taskman;

private {
	import std.stdio;
	import core.stdc.stdio;
	import std.string;
//	import std.date;
	import std.datetime;
	import std.file: FileException;
	import std.algorithm;
	import std.conv: text;

//	import terminal;
	import jtask.taskmanbb, jtask.basebb;
	import base, jmisc, task;
}

class TaskMan {
private:
	Task[] _possibleTasks, // possible tasks are the tasks you choose from
		_doneTasks, // done tasks are the tasks that you have done
		_viewTasks; // for searching and stuff
	int _selectedTaskIndex; // or gotten task to go with 'g' at command module
	//#Possible tasks
	struct TaskHidden {
		int tagNumber;
		string tagName;
		
		this( int tagNumber, string tagName ) {
			this.tagNumber = tagNumber;
			this.tagName = tagName;
		}
	}
	TaskHidden[] tasksHidden;
	string _cformat; // custom format
	string _textTank;
public:
	@property {
		string textTank() { return _textTank; }
		void textTank(string textTank0) { _textTank = textTank0; }
		string cformat() { return _cformat; }
	}

	void resetViewTasks() {
		_viewTasks = _doneTasks;
	}

	auto listFoundText(in string phrase, in bool isWordSearch = false) {
		import std.algorithm: canFind, all;
		import std.string: indexOf, split;

		string result;

		int numberOfItem = 1; //#redundant, why not use cast(int)(i + 1)

		Task[] tasks;
		foreach(i, task; _viewTasks) {
			if ((! isWordSearch && indexOf(task.comment(), phrase) != -1) ||
				(isWordSearch && phrase.split.all!(word => task.comment.canFind(word)))) {
				tasks ~= task;
				immutable tex = task.viewInfo(numberOfItem, cast(int)i, Collum.straitDown, TaskType.done, _cformat);
				_textTank ~= tex;
				result ~= tex;
				numberOfItem++;
			}
		}
		if (tasks.length)
			_viewTasks = tasks;

		return result;
	}

	auto getRange(int start, int end) {
		string result = "\n";

		Task[] tasks;
		foreach(i, task; _doneTasks[start .. end + 1]) {
			immutable tex = task.viewInfo(cast(int)i, cast(int)(start + i), Collum.straitDown, TaskType.done, _cformat);
			tasks ~= task;
			_textTank ~= tex;
			result ~= tex;
		}
		if (tasks.length)
			_viewTasks = tasks;

		return result;
	}

	string printDayOrDays(int fd, int fm, int fy, int tod = 0, int tom = 0, int toy = 0) {
		auto currentDate = cast(DateTime)Clock.currTime();
		try {
			if (tod == 0)
				if (Date(fy, fm, fd) > currentDate.date)
					throw new Exception("From date set in the future");
			if (tod != 0) {
				if (toy < fy)
					throw new Exception("To year, before from year");
				if (Date(toy, tom,tod) > currentDate.date)
					throw new Exception("To date, set in the future");
			}
		} catch(Exception e) {
			return "Error: " ~ e.msg ~ ", check your input..";
		}

		import std.range;

		string result;
		
		int numberOfItem = 1;
		bool found = false;
		bool last = false;
		int iday, im, iy;

		iday=fd;
		im=fm;
		iy=fy;

		Task[] taskTank,
			tasks;

		void doDay(int d, int m, int y) {
			string[] comments;
			Task[] select;
			foreach(i, task; _viewTasks)
				with(task.dateTime)
					if (day == d && month == m && year == y)
						with(task) {
							taskTank ~= new Task(id, taskString,
								timeLength, comment,
								dateTime, displayTimeFlag,
								endTime, displayEndTimeFlag);

							select ~= new Task(id, taskString,
								timeLength, comment,
								dateTime, displayTimeFlag,
								endTime, displayEndTimeFlag);
							select[$ - 1].listNumber = cast(int)i;
							comments ~= comment;
						}
			string categories;
			int cnum;
			foreach(i, task; select) { // loop through all days tasks
				if (comments[i] == "<skip>")
					continue;
				categories = "";
					foreach(j; 0 .. select.length) { // loop through all the comments
						if (select[i].comment == comments[j] && comments[j] != "" && task.comment != "" && j != i) {
							comments[i] = comments[j] = "<skip>";
							categories ~= text(select[j].listNumber, ") ", select[j].id, " - ", select[j].taskString, ", ");
							cnum += 1;
						}
					}

				//# %in - not setup right 4.5.2019
				immutable info = categories ~ task.viewInfo(
					cast(int) + 1, task.listNumber, Collum.straitDown, TaskType.done, _cformat );
				_textTank ~= info;
				tasks ~= task;
				result ~= info;
				numberOfItem++;
				found = true;
			}
		} // doDay

		if (tod != 0)
			while(true) { // while
				doDay(iday, im, iy);

				iday++;
				if (iday > 31) {
					iday = 1;
					im++;
					if (im>12) {
						im = 1;
						iy++;
					}
				}
				if (last)
					break;
				if (iday >= tod && im >= tom && iy >= toy)
					last = true; //#how did the goto get here?
			} // while

		if (tod == 0)
			doDay(fd, fm, fy);

		if (! found) {
			result = "No results!";
		} else {
			if (tasks.length)
				_viewTasks = tasks;
		}

		return result;
	} //#printDay (should be days)
/+
//#can't work it out
//Bible [12:34.56] - read and laydown
//Snooze [12:34.56] - read and laydown
//->
//Bible. Snooze [12:34.56] - read and laydown

		foreach(i, task; taskTank) {
			foreach(i2, task2; taskTank) {
				if (i != i2 && task.comment == task2.comment) {
					result ~= task2.taskString ~ " ";
				} else {
					result ~= 
				}
			}
		}
+/		

	void saveTextTank(string fileName) {
		immutable fileWrite = "w";

		File(fileName, fileWrite).write(_textTank);
	}

	void resetCategorys() {
		_possibleTasks.length = 0;
	}

	void clearHidden() {
		tasksHidden.length = 0;
	}
	
	string showHiddenCategorys() {
		string result;

		foreach(taskh; tasksHidden)
			with(taskh) {
				writefln("%03s %s", tagNumber, tagName);
				result ~= format("%03s %s", tagNumber, tagName);
			}
		
		return result;
	}

	/// return: the number of possible tasks
	size_t getNumberOfPossibleTasks()
	{
		return _possibleTasks.length;
	}

	auto clearStEdL() {
		_doneTasks[ _selectedTaskIndex ].displayTimeFlag = false;
		_doneTasks[ _selectedTaskIndex ].displayEndTimeFlag = false;
		_doneTasks[ _selectedTaskIndex ].setTimeLength(TimeLength(0,0,0));

		return "clearedStEdL";
	}
	
	/// set the time of day
	auto setTime(int hour, int minute,int second) {
		_doneTasks[ _selectedTaskIndex ].setTime(hour, minute, second);

		return format("Set time/start time %s:%s:%s", hour, minute, second);
	}

	/// set the end time of day
	auto setEndTime(int hour, int minute, int second) {
		_doneTasks[ _selectedTaskIndex ].setEndTime(hour, minute, second);

		return format("End time %s:%s:%s", hour, minute, second);
	}

	/// set time length for task
	auto setTimeLength( TimeLength tl )
	{
		_doneTasks[ _selectedTaskIndex ].setTimeLength( tl );

		return text(tl);
	}

	bool noPossibleTasks()
	{
		return _possibleTasks.length == 0;
	}

	size_t numberOfTasks()
	{
		return _doneTasks.length;
	}

	void addPossible(Task possibleTask)
	{
		_possibleTasks ~= possibleTask;
	}

	void opOpAssign(string op)(Task doneTask)
		if (op == "~")
	{
		_doneTasks ~= doneTask;
	}

	Task getPossibleTask(int index) {
		if ( index >= 0 && index < _possibleTasks.length )
			return _possibleTasks[index];
		else {
			//writecln( Color.red, "You are in error!" );
			writeln("taskman.d - Task getPossibleTask(int index) - getPossibleTask out of bounds!");
			return null;
		}
	}
	
	void saveHidden(in string fileName) {
		import std.file;

		immutable fileWriteOnly = "w";
		auto f = File(fileName, fileWriteOnly);

		foreach(taskh; tasksHidden)
			f.writefln("%03s %s", taskh.tagNumber, taskh.tagName);

		f.close();
	}
	

	Task getTask(in int index)
	{
		if ( index < 0 || index >= _doneTasks.length)
		{
			writeln("Task getTask" ~ "(immutable int index)" ~ " - out of bounds (", index, ")");
			return null;
		}
			
		return _doneTasks[index];
	}
	
	void setTaskIndex(in int index)
	{
		if ( index < 0 || index >= _doneTasks.length)
		{
			writeln("value for index is out of bounds in _doneTasks. (", index, ")");
			return;
		}
		_selectedTaskIndex = index;
	}
		
	/// set date
	auto setDate(int date, int month, int year) {
		_doneTasks[_selectedTaskIndex].setDate(date, month, year);

		return format("\nid: %s, d:m:y %s:%s:%s", _selectedTaskIndex, date, month, year);
	}
	
	/// Add some thing said about the log entry (eg. comment)
	auto setComment(string comment)
	{
		_doneTasks[_selectedTaskIndex].setComment(comment);

		return comment;
	}
	
	void viewLast() {
		if ( _doneTasks.length > 0 )
			writefln("%2s - %-40s",
					_doneTasks[$-1].id, _doneTasks[$-1].taskString);
	}
	
	/// Sort list by date and time
	void doSort() {
		//#sort
		sort!("a.getDateTimeForSort() < b.getDateTimeForSort()")(_doneTasks);
		//sort!("a.getDateTime() < b.getDateTime()")(_doneTasks);
	}
	
	//#new
	void customFormatList(string cformat) {
		_cformat = cformat;
	}
	
	void convertToCommands(string fileName) {
		string content;
		foreach ( i, task; _doneTasks ) {
			with(task) {
				content ~= format("%s\n%s\n",
								  catagoryToCommand(),
								  dateToCommand());
				if (comment != "")
					content ~= commentToCommand() ~ "\n";

				if (timeLength != TimeLength(0,0,0))
					content ~= lengthToCommand() ~ "\n";

				if (displayTimeFlag)
					content ~= timeToCommand() ~ "\n";

				if (displayEndTimeFlag)
					content ~= endTimeToCommand() ~ "\n";
			}
		}
		File(fileName, "w").write(content); //#raw write?
		//auto f = File(fileName, "w"); // open for writing
		//f.write(content);
		//f.close;
	}
	
	/// View all possible tasks
	auto view( TaskType taskType, int format = 0 ) {
		string result;

		auto tasks = [_possibleTasks, _doneTasks, _doneTasks][taskType];
		final switch ( taskType )
		{
			case TaskType.possibles:
				bool isHidden( string testTask ) {
					foreach( taskString; tasksHidden )
						if ( testTask == taskString.tagName )
							return true;
					return false;
				}
				//#this does not help for not displaying the possible tasks
				Task[] displayTasks;
				int[] index;
				foreach( i, t; tasks )
					if ( t.taskString != "<skip>" && !isHidden( t.taskString ) ) {
						displayTasks ~= t;
						index ~= cast(int)i;
					}

				//#cannot understand the next two resualts
				//mixin( trace( "displayTasks.length" ) );
				//mixin( trace( "tasks.length" ) );
				switch(format) {
					default: break;
					case 0:
						//bool isDevOfTwo() { return displayTasks.length % 2; }
						//foreach ( i; 0 .. displayTasks.length / 2 + ( isDevOfTwo ? 1 : 0 ) ) {
						foreach ( i; 0 .. (displayTasks.length + (displayTasks.length % 2 == 0 ? 0 : 1)) / 2) {
							result ~= displayTasks[ i ].viewInfo(
								0,
								index[i],
								Collum.left,
								TaskType.possibles
							); // left
							if ( displayTasks.length / 2 + i < tasks.length ) {
								result ~= displayTasks[ cast(uint)displayTasks.length / 2 + i ].viewInfo(
									0, cast(int)displayTasks.length / 2 + cast(int)i, Collum.right, TaskType.possibles ); // right
							} else
								writeln();
						}
					break;
					case 1:
						foreach(i; 0 .. displayTasks.length) {
							result ~= displayTasks[i].viewInfo(
								0,
								index[i],
								Collum.left, // ?
								TaskType.possibles
							) ~ "\n";
						}
					break;
				}
			break;
			case TaskType.done:
				int offSet = tasks.length > 30 ? cast(int)tasks.length - 30 : 0;
				foreach ( i, task; tasks[ offSet .. $ ] )
				{
					immutable tex = task.viewInfo( cast(int)i, offSet + cast(int)i, Collum.straitDown, TaskType.done, _cformat );
					_textTank ~= tex;
					result ~= tex;			
				}
			break;
			case TaskType.allDone:
				foreach(i, task; tasks) {
					immutable tex = task.viewInfo( cast(int)i, cast(int)i, Collum.straitDown, TaskType.done, _cformat );
					_textTank ~= tex;
					result ~= tex;
				}
			break;
		}

		return result;
	}
	
	/// I/O output
	void saveToTextFile( in string fileName )
	{
		string content;
		foreach ( i, task; _doneTasks )
		{
			content ~= task.doneString( 0, cast(int)i ) ~ '\n';
		}
		auto f = File( fileName, "w"); // open for writing
		f.write( content );
		f.close;
	}
	
	/// remove from the done tasks list
	auto removeAt(int index)
	{
		string result = "\n";

		if ( index < _doneTasks.length && index >= 0 )
		{
			result ~= "Deleting (enter 'ld' to revert to last save) - " ~ _doneTasks[index].viewInfo(0, index, TaskType.done);
			_doneTasks = _doneTasks[0 .. index] ~ _doneTasks[index + 1 .. $];
		}
		else
		{
			result ~= "That, my friend, is an invalid number.";
		}

		return result;
	}
	
//		void viewInfo( int indexNumber, int collum, TaskType taskType = TaskType.possibles )

	/// List just by the selected type (eg. 'got up', but its number)
	auto listByType(int[] typeIds, string cformat)
	{
		string result = "\n";

		int numberOfItem = 1;

		Task[] tasks;
		foreach ( i, task; _viewTasks ) {
			foreach(typeId; typeIds)
				if ( task.id == typeId ) {
					tasks ~= task;
					immutable tex = task.viewInfo( numberOfItem, cast(int)i, Collum.straitDown, TaskType.done, _cformat );
					_textTank ~= tex;
					result ~= tex;
					numberOfItem++;
				}
		}
		if (tasks.length)
			_viewTasks = tasks;

		return result;
	}

	void clearDoneTasks()
	{
		_doneTasks.length = 0;
	}
	
	void saveDoneTasks(string filename)
	{
		TaskManbb tmbb;
		//	this( int  id, string taskString, TimeLength length0, string comment, DateTime dateTime,
//		  bool displayTimeFlag ) {

		// loop through all the tasks and add them to tmbb.tasksbb
		foreach( task; _doneTasks ) {
			scope( failure ) {
				writeln( "id: ", task.id );
			}
			with( task ) {
				tmbb.tasksbb ~= new Taskbb( id, _possibleTasks[ id ].taskString, timeLength, comment,
					                        dateTime, displayTimeFlag, endTime, displayEndTimeFlag );
			}
		}
		tmbb.saveDoneTasksbb( filename );
	}
	
	/// Load tasks that are done
	void loadDoneTasks(string filename) {
		_doneTasks.length = 0;
		TaskManbb tmbb;
		tmbb.loadDoneTasksbb( filename );
		foreach( taskbb; tmbb.tasksbb ) {
			with( taskbb )
				_doneTasks ~= new Task( id, taskString, timeLength, comment,
				dateTime, displayStartTimeFlag,
				endTime, displayEndTimeFlag );
		}
	}
	
	//#Possible tasks
	void addHidden( int tagNumber, string tagName ) {
		tasksHidden ~= TaskHidden( tagNumber, tagName );
	}
}
