module platform;

version (Windows) {}
else pragma(msg, "warning: This is supposed to be a Windows tool but okay...");

enum CHOD_VERSION = "0.0.0";