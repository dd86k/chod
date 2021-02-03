module commands;

import std.stdio;
import api.common;
import api.v2.client;
import logging;

private enum KEY_OFFICIAL   = "79d02ea9cad655eb";
private enum KEY_UNOFFICIAL = "fd112f53c3ab578c";
private enum PUSH_OFFICIAL  = "https://push.chocolatey.org/";
private enum URL_OFFICIAL   = "https://chocolatey.org/api/v2/";
private enum URL_LICENSED   = "https://licensedpackages.chocolatey.org/api/v2/";

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
		size_t dlen = pkg.summary.length;
		with (pkg)
		writef("%s\n\t%s\n\n",
			title,
			dlen > 70 ? summary[0..67]~"..." : summary);
	}
	
	return 0;
}

int info(string pkgname)
{
	Package[] pkgs;
	
	if (apiInfo(pkgs, URL_OFFICIAL, pkgname))
		return 1;
	
	if (pkgs.length == 0)
	{
		logError("No packages found");
		return 1;
	}
	
	Package pkg = pkgs[0];
	
	with (pkg)
	{
		writef(
		"Id: %s\n"~
		"Title: %s\n"~
		"Summary: %s\n"~
		"Updated: %s\n"~
		"Authors: ",
		id,
		title,
		summary,
		updated
		);
		foreach (i, author; authors)
		{
			if (i) write(", ");
			write(author);
		}
		writeln;
	}
	with (pkg.properties)
	{
		writef(
		"Version: %s\n"~
		"Title: %s\n"~
		"Description: %s\n"~
		"Tags:%s\n"~
		"Copyright: %s\n"~
		"Created: %s\n"~
		"Downloads: %s | Version: %s\n"~
		"GalleryDetailsUrl: %s\n"~
		"Published: %s\n"~
		"IsLatestVersion: %s\n"~
		"IsAbsoluteLatestVersion: %s\n"~
		"Hash: (%s) %s\n"~
		"PackageSize: %s\n"~
		"ProjectUrl: %s\n",
		version_,
		title,
		description,
		tags,
		copyright,
		created,
		downloadCount,
		versionDownloadCount,
		galleryDetailsUrl,
		published,
		isLatestVersion,
		isAbsoluteLatestVersion,
		hashAlgo,
		hash,
		packageSize,
		projectUrl
		);
	}
	
	return 0;
}