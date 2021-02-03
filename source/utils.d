module utils;

public import std.datetime;
import std.conv, std.exception, std.string;
import std.utf : byCodeUnit;
import std.algorithm.searching : countUntil;

bool tryParse(ref DateTime dt, string s)
{
	// 2020-01-01T20:00:00Z
	if (s.length < 18)
		return false;
	
	try
	{
		// NOTE: TimeOfDay.fromISOString counts the Z and trips
		//dt = DateTime.fromISOExtString(s);
		int year = to!int(s[0..4]);
		int month = to!int(s[5..7]);
		int day = to!int(s[8..9]);
		Date date = Date(year, month, day);
		
		int hour = to!int(s[11..13]);
		int minute = to!int(s[14..16]);
		int seconds = to!int(s[17..19]);
		TimeOfDay time = TimeOfDay(hour, minute, seconds);
		
		dt = DateTime(date, time);
		
		return false;
	}
	catch (Exception)
	{
		return true;
	}
}

bool tryParse(ref int i32, string s)
{
	try
	{
		i32 = parse!int(s);
		return false;
	}
	catch (Exception)
	{
		return true;
	}
}

bool tryParse(ref long i64, string s)
{
	try
	{
		i64 = parse!long(s);
		return false;
	}
	catch (Exception)
	{
		return true;
	}
}

bool tryParse(ref bool b, string s)
{
	try
	{
		b = parse!bool(s);
		return false;
	}
	catch (Exception)
	{
		return true;
	}
}