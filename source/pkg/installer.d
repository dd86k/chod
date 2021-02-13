module pkg.installer;

import std.file, std.path, std.zip, std.typecons;
import logging, meta;

int archiveUnpack(string installDir, string tmpDir, string sourceFile)
{
	try
	{
		string basePath = tmpDir ~
			sourceFile.baseName.stripExtension;
		
		if (exists(basePath) == false)
			mkdir(basePath);
		
		string inpath   = absolutePath(installDir);
		string origpath = getcwd;
		chdir(basePath);
		
		auto zip = scoped!ZipArchive(read(sourceFile));
		
		foreach (name, ArchiveMember m; zip.directory)
		{
			ubyte[] md = zip.expand(m); /// member data
			
			string dn = dirName(m.name); /// directory name
			string fn = baseName(m.name); /// file name
			if (dn != ".")
			{
				mkdirRecurse(dn);
			}
			
			write(dn ~ dirSeparator ~ fn, md);
		}
		
		if (exists("tools") == false)
		{
			logError("archive: tools folder does not exist");
			return 1;
		}
		
		foreach (DirEntry entry; dirEntries("tools", "*.exe", SpanMode.shallow))
		{
			string name = entry.name;
			copy(name, inpath ~ name.baseName, PreserveAttributes.yes);
		}
		
		chdir(origpath);
	}
	catch (Exception ex)
	{
		debug logError("archive: %s", ex);
		else  logError("archive: %s", ex.msg);
		return 1;
	}
	
	return 0;
}

//TODO: int acrhivePack(string targetFile, string sourceNuspec)