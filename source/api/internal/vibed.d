module api.internal.vibed;

import std.algorithm.searching : canFind;
import vibe.http.client, vibe.stream.operations;
import logging;

enum USER_AGENT = "NuGet/0.10.15.0 (Microsoft Windows NT 10.0.19042.0)";

int httpGet(ref string xml, string url, bool checkxml = true)
{
	try
	{
		HTTPClientResponse res = requestHTTP(url);
		
		if (checkxml)
		if (canFind(res.contentType, "xml") == false)
		{
			logError("http: URL '%s' not a XML Content-Type", url);
			return 2;
		}
		
		if (res.statusCode != 200)
		{
			logError("http: URL '%s' returned code %d", url, res.statusCode);
			return 2;
		}
		
		xml = res.bodyReader.readAllUTF8();
		return 0;
	}
	catch (Exception ex)
	{
		debug logError("URL '%s' exception - %s", url, ex);
		else  logError("URL '%s' exception - %s", url, ex.msg);
		return 2;
	}
}

int httpDownload(string path, string url)
{
	import std.stdio;
	import eventcore.driver : IOMode;
	import vibe.inet.urltransfer : download;
	import vibe.stream.operations : readAll;
	try
	{
		download(url, (scope res)
		{
			try
			{
				File f = File(path, "wb");
				f.rawWrite(res.readAll());
			}
			catch (Exception ex)
			{
				debug logError("download-sub: %s", ex);
				else  logError("download-sub: %s", ex.msg);
			}
		});
		
		return 0;
	}
	catch (Exception ex)
	{
		debug logError("download: %s", ex);
		else  logError("download: %s", ex.msg);
		return 1;
	}
}