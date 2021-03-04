module main;

import std.stdio, std.getopt, std.file;
import std.path : dirSeparator;
import core.stdc.stdlib : exit;
import platform, logging, commands, meta;

enum PRE_HELP =
	"chod - Alternative Chocolatey client\n"~
	" Usage: chod COMMAND [OPTIONS]\n"~
	"\n"~
	"Commands:\n"~
	" search           Search package name\n"~
	" info             Show package information\n"~
	" install          Install package\n"~
	"\n"~
	"Global options:\n";

enum LICENSE = 
`BSD 3-Clause "New" or "Revised" License

Copyright (c) 2021 dd <dd@dax.moe>. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
`;

enum VERSION = "chod "~CHOD_VERSION~" (built: "~__TIMESTAMP__~")";

void printVersion()
{
	writeln(VERSION);
	exit(0);
}

void printOptions(Option[] options)
{
	options[$-1].help = "Print this help page and exit";
	foreach (opt; options)
	{
		with (opt)
		if (optShort)
			writefln(" %s, %-12s %s", optShort, optLong, help);
		else
			writefln(" %-16s %s", optLong, help);
	}
}

int prepInstallPath(ref CommandOptions opts)
{
	// install path
	if (opts.installPath)
	{
		try
		{
			if (isDir(opts.installPath) == false)
			{
				logError("main: temporary path '%s' is not a directory",
					opts.tempPath);
				return 1;
			}
		}
		catch (Exception ex)
		{
			debug logError("main: %s", ex);
			else  logError("main: %s", ex.msg);
			return 1;
		}
	}
	else // no install path given
	{
		import std.process : environment;
		version (Windows)
		{
			string programData = environment.get("ProgramData", `C:\ProgramData`);
			programData ~= `\chocolatey\bin`;
			
			if (exists(programData))
			{
				opts.installPath = programData ~ `\`;
			}
		}
		
		if (opts.installPath == null)
		{
			logWarn("Warning: No install path found, installing in current directory");
			opts.installPath = "." ~ dirSeparator;
		}
	}
	
	return 0;
}

int prepTempPath(ref CommandOptions opts)
{
	if (opts.tempPath)
	{
		try
		{
			if (isDir(opts.tempPath) == false)
			{
				logError("main: temporary path '%s' is not a directory",
					opts.tempPath);
				return 1;
			}
		
			if (opts.tempPath[$-1] != dirSeparator[0])
				opts.tempPath ~= dirSeparator;
		}
		catch (Exception ex)
		{
			debug logError("main: %s", ex);
			else  logError("main: %s", ex.msg);
			return 1;
		}
	}
	else // no temporary path given
	{
		version (Windows) // blame GetTempPathA
			opts.tempPath = tempDir ~ "chod";
		else
			opts.tempPath = tempDir ~ dirSeparator ~ "chod";
		
		try
		{
			if (exists(opts.tempPath))
			{
				if (isDir(opts.tempPath) == false)
				{
					logError("main: '%s' is not a usable directory",
						opts.tempPath);
					return 1;
				}
			}
			else
			{
				mkdir(opts.tempPath);
			}
		}
		catch (Exception ex)
		{
			debug logError("main: %s", ex);
			else  logError("main: %s", ex.msg);
			return 1;
		}
		
		opts.tempPath ~= dirSeparator;
	}
	
	return 0;
}

int main(string[] args)
{
	if (args.length < 2)
	{
		logError("Need command argument. Invoke with 'help' to see list");
		return 1;
	}
	
	CommandOptions opts;	/// global and command options
	string command = args[1];	/// command string e.g. "info"
	GetoptResult r = void;	/// getopt result
	
	try
	{
		r = args.getopt(
			config.caseSensitive,
			config.passThrough,
			"loglevel", "Set stdout loglevel", &opts.loglevel,
			"T|temppath", "Set temporary path", &opts.tempPath,
			"P|installpath", "Set installation path", &opts.installPath,
		);
	}
	catch (Exception ex)
	{
		logError(ex.msg);
		return 1;
	}
	
	// log level
	if (opts.loglevel != LogLevel.info)
		setLogLevel(opts.loglevel);
	
	bool helpWanted = r.helpWanted; // let getopt recompile opts for command
	bool placeholder = void;
	switch (command)
	{
	case "search":
		try
		{
			r = args.getopt(
				config.caseSensitive,
				config.noPassThrough,
				"placeholder", "does nothing", &placeholder
			);
		}
		catch (Exception ex)
		{
			logError(ex.msg);
			return 1;
		}
		
		if (helpWanted)
		{
			writeln("Search options:");
			printOptions(r.options);
			return 0;
		}
		
		if (args.length < 3) // chod search xxx
		{
			logError("Missing package argument");
			return 1;
		}
		
		return search(args[2], opts);
	case "info":
		try
		{
			r = args.getopt(
				config.caseSensitive,
				config.noPassThrough,
				"placeholder", "does nothing", &placeholder
			);
		}
		catch (Exception ex)
		{
			logError(ex.msg);
			return 1;
		}
		
		if (helpWanted)
		{
			writeln("Info options:");
			printOptions(r.options);
			return 0;
		}
		
		if (args.length < 3) // chod info xxx
		{
			logError("Missing package argument");
			return 1;
		}
		
		return info(args[2], opts);
	case "install":
		try
		{
			r = args.getopt(
				config.caseSensitive,
				config.noPassThrough,
				"D|download", "Only download package to current directory", &opts.downloadOnly,
				"f|file", "Install Nupkg file", &opts.installFile,
			);
		}
		catch (Exception ex)
		{
			logError(ex.msg);
			return 1;
		}
		
		if (helpWanted)
		{
			writeln("Install options:");
			printOptions(r.options);
			return 0;
		}
		
		if (args.length < 3) // chod install xxx
		{
			logError("Missing package argument");
			return 1;
		}
		
		if (prepInstallPath(opts))
			return 1;
		if (prepTempPath(opts))
			return 1;
		
		return install(args[2], opts);
	case "version", "--version":
		enum S = VERSION~"\nBackends:";
		write(S);
		version (Have_vibe_d_http) write(" vibe-d");
		version (Have_dxml) write(" dxml");
		writeln;
		break;
	case "help", "--help":
		write(PRE_HELP);
		printOptions(r.options);
		writeln;
		debug writeln("Druntime GC help: --DRT-gcopt=help");
		writeln("For command help: chod <command> --help");
		break;
	case "license":
		write(LICENSE);
		break;
	default:
		logError("Unknown command '%s'", command);
		return 1;
	}
	
	return 0;
}
