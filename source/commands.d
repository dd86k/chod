module commands;

import std.stdio;
import meta, api.v2.client;
import pkg.verifier, pkg.installer;
import logging;

private enum KEY_OFFICIAL   = "79d02ea9cad655eb";
private enum KEY_UNOFFICIAL = "fd112f53c3ab578c";
private enum PUSH_OFFICIAL  = "https://push.chocolatey.org/";
private enum URL_OFFICIAL   = "https://chocolatey.org/api/v2/";
private enum URL_LICENSED   = "https://licensedpackages.chocolatey.org/api/v2/";

int search(string pkgname, ref CommandOptions opts)
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

int info(string pkgname, ref CommandOptions opts)
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

int install(string pkgname, ref CommandOptions opts)
{
	Package[] pkgs;
	
	logInfo("Fetching information...");
	
	if (apiInfo(pkgs, URL_OFFICIAL, pkgname))
		return 1;
	
	if (pkgs.length == 0)
	{
		logError("No packages found");
		return 1;
	}
	
	Package pkg = pkgs[0];
	
	if (pkg.packageUrl == null)
	{
		logError("Package is missing its URL");
		return 1;
	}
	if (pkg.properties.packageSize <= 0)
	{
		logError("Package size cannot be 0");
		return 1;
	}
	if (pkg.properties.hashAlgo == null)
	{
		logError("Package is missing the hash algorithm type");
		return 1;
	}
	if (pkg.properties.hash == null)
	{
		logError("Package is missing its hash");
		return 1;
	}
	
	string title  = pkg.title~"."~pkg.properties.version_;
	string packageName = title~".nupkg";
	
	logInfo("GET '%s'", pkg.packageUrl);
	
	string archivePath = opts.downloadOnly ?
		packageName : // cwd
		opts.tempPath ~ packageName;
	
	if (apiDownload(archivePath, pkg.packageUrl))
		return 1;
	
	logInfo("File '%s' saved, checking '%s' hash...", packageName, pkg.properties.hashAlgo);
	
	if (verifyHash(archivePath, pkg.properties.hashAlgo, pkg.properties.hash))
		return 1;
	
	if (opts.downloadOnly)
	{
		logInfo("Package hash verified");
		return 0;
	}
	
	logInfo("Package hash verified, extracting...");
	
	with (opts)
	if (archiveUnpack(installPath, tempPath, archivePath))
		return 1;
	
	logInfo("Package installed in '%s'", opts.installPath);
	
	return 0;
}