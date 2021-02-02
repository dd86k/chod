module commands;

import std.stdio;
import api.common;
import api.v2.client;
import logging;

private enum KEY_OFFICIAL     = "79d02ea9cad655eb";
private enum KEY_UNOFFICIAL   = "fd112f53c3ab578c";
private enum PUSH_OFFICIAL    = "https://push.chocolatey.org/";
private enum URL_OFFICIAL = "https://chocolatey.org/api/v2/";
private enum URL_LICENSED = "https://licensedpackages.chocolatey.org/api/v2/";

int search(string pkgname)
{
	Package[] pkgs;
	
	if (apiSearch(pkgs, URL_OFFICIAL, pkgname))
		return 1;
	
	if (pkgs.length == 0)
	{
		logError("No packages found");
		return 1;
	}
	
	foreach (pkg; pkgs)
	{
		size_t dlen = pkg.description.length;
		with (pkg)
		writef("%s\n\t%s\n\n",
			name,
			dlen > 70 ? description[0..67]~"..." : description);
	}
	
	return 0;
}

int show(string pkgname)
{
	
	
	return 0;
}