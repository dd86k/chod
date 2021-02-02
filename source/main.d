module main;

import std.stdio, std.getopt;
import core.stdc.stdlib : exit;
import platform;
import logging;
import commands;

// https://docs.chocolatey.org/en-us/choco/commands/
//TODO: command: agent -- run as agent
//TODO: command: clean -- clean pkg cache
//TODO: command: show -- show pkg description

//TODO: -k/--key api key
//TODO: -U/--url additional endpoint
//TODO: -c/--credentials user:pass

void printVersion()
{
	enum S = "chod "~CHOD_VERSION~" (built: "~__TIMESTAMP__~")";
	writeln(S);
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

int main(string[] args)
{
	if (args.length < 2)
	{
		logError("Need command argument. Invoke with 'help' to see list");
		return 1;
	}
	
	string command = args[1];
	
	// General options
	bool placeholder = void;
	GetoptResult r = void;
	try
	{
		r = args.getopt(
			config.caseSensitive,
			config.passThrough,
			"placeholder", "does nothing", &placeholder,
		);
	}
	catch (Exception ex)
	{
		logError(ex.msg);
		return 1;
	}
	
	bool helpWanted = r.helpWanted; // let getopt recompile opts for command
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
			logError("Missing search argument");
			return 1;
		}
		return search(args[2]);
	case "version", "--version":
		enum S = "chod "~CHOD_VERSION~" (built: "~__TIMESTAMP__~")";
		writeln(S);
		write("Backends:");
		version (Have_vibe_d_http) write(" vibe-d");
		version (Have_dxml) write(" dxml");
		writeln;
		break;
	case "help", "--help":
		write(
		"chod - Alternative Chocolatey client\n"~
		" Usage: chod COMMAND [OPTIONS]\n"~
		"\n"~
		"Commands:\n"~
		" search           Search package name\n"~
		"\n"~
		"Global options:\n");
		printOptions(r.options);
		debug writeln("\nDruntime GC help: --DRT-gcopt=help");
		writeln("\nFor command help: chod <command> --help");
		break;
	case "license":
		write(
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
`
		);
		break;
	default:
		logError("Unknown command '%s'", command);
		return 1;
	}
	
	return 0;
}
