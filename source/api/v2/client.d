module api.v2.client;

import std.string, std.format, std.typetuple;
import common;
import api.internal.dxml;
import api.internal.vibed;

private enum INSTALL_PATH = "C:\\ProgramData\\Chocolatey";
private enum LOCAL_SYSTEM_SID = "S-1-5-18";

private immutable string HTTPS = "https://";
private immutable string APIV2 = "api/v2/";

string apiPrepUrl(string url)
{
	string u = url;
	
	// e.com -> https://e.com
	if (startsWith(u, HTTPS) == false)
	{
		u = HTTPS ~ u;
	}
	
	// https://e.com -> http://e.com/
	// https://e.com/api/v2 -> http://e.com/api/v2/
	if (endsWith(u, "/") == false)
	{
		u ~= "/";
	}
	
	// https://e.com/ -> https://e.com/api/v2/
	if (endsWith(u, APIV2) == false)
	{
		u ~= APIV2;
	}
	
	return u;
}

void apiMetadata(string url)
{
	static immutable string METADATA = "$metadata";
	string s;
	httpGet(s, url~METADATA);
	
	
}

int apiSearch(ref Package[] pkgs, string url, string name)
{
	url = apiPrepUrl(url);
	url ~= "Search()?"~
		"$filter=IsLatestVersion&"~
		"$skip=0&"~
		"$top=30&"~
		"searchTerm='"~name~"'&"~
		"targetFramework=''&"~
		"includePrerelease=false";
	
	string xml;
	if (httpGet(xml, url))
		return 1;
	
	return parsePackages(pkgs, xml);
}

int apiInfo(ref Package[] pkgs, string url, string name)
{
	url = apiPrepUrl(url);
	url ~= "Packages()?"~
		"$filter=(tolower(Id)%20eq%20'"~name~"')%20and%20IsLatestVersion";
	
	string xml;
	if (httpGet(xml, url))
		return 1;
	
	return parsePackages(pkgs, xml);
}

int apiDownload(string path, string url)
{
	if (httpDownload(path, url))
		return 1;
	
	return 0;
}