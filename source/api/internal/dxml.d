module api.internal.dxml;

import logging;
import api.common;
import dxml.dom;

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
		foreach (i, c; feed.children)
		{
			if (c.type != EntityType.elementStart)
				continue;
			
			if (c.name != "entry")
				continue;
			
			// <entry>
			Package pkg;
			foreach (entry_index, entry; c.children)
			{
				if (entry.type != EntityType.elementStart)
					continue;
				
				if (entry.children.length < 1)
					continue;
				
				switch (entry.name)
				{
				case "id":
					pkg.id = entry.children[0].text;
					break;
				case "title":
					pkg.name = entry.children[0].text;
					break;
				case "summary":
					pkg.description = entry.children[0].text;
					break;
				default: continue;
				}
			}
			
			pkgs ~= pkg; // add to list
		}
		
		return 0;
	}
	catch (Exception ex)
	{
		import std.stdio;
		debug logFatal("parser: %s", ex);
		else  logFatal("parser: %s", ex.msg);
		return 3;
	}
}