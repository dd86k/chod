module api.internal.dxml;

import std.stdio;
import utils, logging;
import common;
import dxml.dom;

private
void parseProperties(ref Package pkg, DOMEntity!string entry)
{
	foreach (prop; entry.children)
	{
		if (prop.type != EntityType.elementStart)
			continue;
		
		if (prop.children.length < 1)
			continue;
		
		with (pkg.properties)
		switch (prop.name)
		{
		case "d:Version":
			version_ = prop.children[0].text;
			continue;
		case "d:Title":
			title = prop.children[0].text;
			continue;
		case "d:Description":
			description = prop.children[0].text;
			continue;
		case "d:Tags":
			tags = prop.children[0].text;
			continue;
		case "d:Copyright":
			copyright = prop.children[0].text;
			continue;
		case "d:Created":
			tryParse(created, prop.children[0].text);
			continue;
		case "d:Published":
			tryParse(published, prop.children[0].text);
			continue;
		case "d:DownloadCount":
			tryParse(downloadCount, prop.children[0].text);
			continue;
		case "d:VersionDownloadCount":
			tryParse(versionDownloadCount, prop.children[0].text);
			continue;
		case "d:GalleryDetailsUrl":
			galleryDetailsUrl = prop.children[0].text;
			continue;
		case "d:IsLatestVersion":
			tryParse(isLatestVersion, prop.children[0].text);
			continue;
		case "d:IsAbsoluteLatestVersion":
			tryParse(isAbsoluteLatestVersion, prop.children[0].text);
			continue;
		case "d:PackageHash":
			hash = prop.children[0].text;
			continue;
		case "d:PackageHashAlgorithm":
			hashAlgo = prop.children[0].text;
			continue;
		case "d:PackageSize":
			tryParse(packageSize, prop.children[0].text);
			continue;
		case "d:ProjectUrl":
			projectUrl = prop.children[0].text;
			continue;
		default: continue;
		}
	}
}

private
void parseEntry(ref Package pkg, DOMEntity!string c)
{
	foreach (entry; c.children)
	{
			
		if (entry.type != EntityType.elementStart)
			continue;
		
		size_t nchilds = entry.children.length;
		
		with (pkg)
		switch (entry.name)
		{
		case "id":
			if (nchilds)
				id = entry.children[0].text;
			continue;
		case "title":
			if (nchilds)
				title = entry.children[0].text;
			continue;
		case "summary":
			if (nchilds)
				summary = entry.children[0].text;
			continue;
		case "updated":
			tryParse(updated, entry.children[0].text);
			continue;
		case "author":
			if (nchilds)
			foreach (name; entry.children)
			{
				if (name.children.length == 0)
					continue;
				authors ~= name.children[0].text;
			}
			continue;
		case "content":
			foreach (attribute; entry.attributes)
			{
				switch (attribute.name)
				{
				case "type":
					packageMime = attribute.value;
					continue;
				case "src":
					packageUrl = attribute.value;
					continue;
				default:
				}
			}
			continue;
		case "m:properties":
			if (nchilds)
				parseProperties(pkg, entry);
			continue;
		default: continue;
		}
	}
}

int parsePackages(ref Package[] pkgs, string xml)
{
	try
	{
		auto dom = parseDOM!simpleXML(xml);
		
		if (dom.children.length < 1)
		{
			logError("parser: no children");
			return 3;
		}
		
		// find <feed>
		size_t child_index = -1;
		foreach (i, c; dom.children)
		{
			if (c.type != EntityType.elementStart)
				continue;
			
			if (c.name != "feed")
				continue;
				
			child_index = i;
			break;
		}
		
		if (child_index == -1)
		{
			logError("parser: <feed> not found");
			return 3;
		}
		
		auto feed = dom.children[child_index];
		
		// find every <entry>
		foreach (c; feed.children)
		{
			if (c.type != EntityType.elementStart)
				continue;
			
			if (c.name != "entry")
				continue;
			
			Package pkg;
			parseEntry(pkg, c); // parse <entry>
			pkgs ~= pkg; // add to list
		}
		
		return 0;
	}
	catch (Exception ex)
	{
		debug logError("parser: %s", ex);
		else  logError("parser: %s", ex.msg);
		return 3;
	}
}