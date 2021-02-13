module pkg.verifier;

import std.stdio, std.digest.sha;
import logging;
	
private union Hashes
{
	SHA512 sha512;
}

private int hashFile(ref string hash, ref File file, string type)
{
	import std.base64;
	
	Hashes h;
	
	switch (type)
	{
	case "SHA512": // SHA-2-512
		foreach (ubyte[] chunk; file.byChunk(1024 * 64))
		{
			h.sha512.put(chunk);
		}
		hash = Base64.encode(h.sha512.finish);
		break;
	default:
		logError("hash: Unknown type '%s'", type);
		return 1;
	}
	
	
	
	return 0;
}

int verifyHash(string path, string type, string hash)
{
	File file;
	
	try
	{
		file.open(path);
	}
	catch (Exception ex)
	{
		debug logError("hash: %s", ex);
		else  logError("hash: %s", ex.msg);
	}
	
	return verifyHash(file, type, hash);
}

int verifyHash(ref File file, string type, string pkgHash)
{
	string fileHash;
	
	if (hashFile(fileHash, file, type))
		return 1;
	
	bool mismatch = pkgHash != fileHash;
	
	if (mismatch)
	{
		logError("hash: Hash mismatch");
	}
	
	return mismatch;
}