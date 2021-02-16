module platform;

version (Windows) {}
else pragma(msg, "WARNING: This is mainly a Windows tool. You may encounter serious bugs.");

enum CHOD_VERSION = "0.0.0";