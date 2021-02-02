module api.common;

import std.datetime;

/// 
// Basically, .NET data types
enum MetaType
{
	EdmString,
	EdmDateTime,
	EdmInt32,
	EdmInt64,
	EdmBoolean,
}

enum MetaName
{
	Id	= "Id",
	Version	= "Version",
	Title	= "Title",
	Summary	= "Summary",
	Description	= "Description",
	Tags	= "Tags",
	Authors	= "Authors",
	Copyright	= "Copyright",
	Created	= "Created",
	Dependencies	= "Dependencies",
	DownloadCount	= "DownloadCount",
	VersionDownloadCount	= "VersionDownloadCount",
	GalleryDetailsUrl	= "GalleryDetailsUrl",
	ReportAbuseUrl	= "ReportAbuseUrl",
	IconUrl	= "IconUrl",
	IsLatestVersion	= "IsLatestVersion",
	IsAbsoluteLatestVersion	= "IsAbsoluteLatestVersion",
	IsPrerelease	= "IsPrerelease",
	Language	= "Language",
	LastUpdated	= "LastUpdated",
	Published	= "Published",
	LicenseUrl	= "LicenseUrl",
	RequireLicenseAcceptance	= "RequireLicenseAcceptance",
	PackageHash	= "PackageHash",
	PackageHashAlgorithm	= "PackageHashAlgorithm",
	PackageSize	= "PackageSize",
	ProjectUrl	= "ProjectUrl",
	ReleaseNotes	= "ReleaseNotes",
	ProjectSourceUrl	= "ProjectSourceUrl",
	PackageSourceUrl	= "PackageSourceUrl",
	DocsUrl	= "DocsUrl",
	MailingListUrl	= "MailingListUrl",
	BugTrackerUrl	= "BugTrackerUrl",
	IsApproved	= "IsApproved",
	PackageStatus	= "PackageStatus",
	PackageSubmittedStatus	= "PackageSubmittedStatus",
	PackageTestResultUrl	= "PackageTestResultUrl",
	PackageTestResultStatus	= "PackageTestResultStatus",
	PackageTestResultStatusDate	= "PackageTestResultStatusDate",
	PackageValidationResultStatus	= "PackageValidationResultStatus",
	PackageValidationResultDate	= "PackageValidationResultDate",
	PackageCleanupResultDate	= "PackageCleanupResultDate",
	PackageReviewedDate	= "PackageReviewedDate",
	PackageApprovedDate	= "PackageApprovedDate",
	PackageReviewer	= "PackageReviewer",
	IsDownloadCacheAvailable	= "IsDownloadCacheAvailable",
	DownloadCacheStatus	= "DownloadCacheStatus",
	DownloadCacheDate	= "DownloadCacheDate",
	DownloadCache	= "DownloadCache",
	PackageScanStatus	= "PackageScanStatus",
	PackageScanResultDate	= "PackageScanResultDate",
}

//-/ Represents a field of data for a package
/*struct PackageMeta
{
	string name;
	MetaType type;
	bool nullable;
	public union
	{
		string vstring;
		bool vbool;
		int vi32;
		long vi64;
	}
}*/

/// 
struct Package
{
	string id;
	string name;
	string description;
	DateTime published;
}
