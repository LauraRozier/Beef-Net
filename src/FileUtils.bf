using System;

namespace Beef_Net
{
	[CRepr]
	public struct SearchRec
	{
		public int64 Time;
		public int64 Size;
		public int32 Attr;
		public char16* Name;
		public int32 ExcludeAttr;
		public Windows.FindHandle FindHandle;
		public Windows.NativeFindData FindData;

		public DateTime TimeStamp { get { return DateTime.FromFileTime(Time); } }
	}

	public class FileUtils
	{
		public static int32 FindMatch(ref SearchRec aF, ref char16* aName)
		{
			// Find file with correct attribute
			while (aF.FindData.mFileAttributes & aF.ExcludeAttr != 0)
				if (!Windows.FindNextFileW(aF.FindHandle, ref aF.FindData))
					return Windows.GetLastError();

			// Convert some attributes back
			aF.Time = (int64)aF.FindData.mLastWriteTime;
			aF.Size = aF.FindData.mFileSize.Value;
			aF.Attr = aF.FindData.mFileAttributes;
			aName = &aF.FindData.mFileName[0];
			return 0;
		}

		public static void InternalFindClose(ref Windows.FindHandle aHandle, ref Windows.NativeFindData aFindData)
		{
		   	if (!aHandle.IsInvalid)
			{
			    Windows.FindClose(aHandle);
			    aHandle = .InvalidHandle;
		    }
		}

		public static int32 InternalFindFirst(StringView aPath, int32 aAttr, ref SearchRec aRslt, ref char16* aName)
		{
			aName = aPath.ToScopedNativeWChar!();
			aRslt.Attr = aAttr;
			// $1e = faHidden or faSysFile or faVolumeID or faDirectory
			aRslt.ExcludeAttr = (~aAttr) & 0x1E;

			// FindFirstFile is a Win32 Call
			aRslt.FindHandle = Windows.FindFirstFileW(aPath.ToScopedNativeWChar!(), ref aRslt.FindData);

			if (aRslt.FindHandle.IsInvalid)
				return Windows.GetLastError();

			// Find file with correct attribute
			int32 result = FindMatch(ref aRslt, ref aName);

			if (result != 0)
				InternalFindClose(ref aRslt.FindHandle, ref aRslt.FindData);

			return result;
		}

		public static int32 InternalFindNext(ref SearchRec aRslt, ref char16* aName) =>
		  	Windows.FindNextFileW(aRslt.FindHandle, ref aRslt.FindData)
				? FindMatch(ref aRslt, ref aName)
		    	: Windows.GetLastError();

		public static int FindFirst(StringView aPath, int32 aAttr, ref SearchRec aRslt)
		{
			int result = InternalFindFirst(aPath, aAttr, ref aRslt, ref aRslt.Name);
			/*
		  	if (result == 0)
		    	SetCodePage(Rslt.Name, DefaultRTLFileSystemCodePage);
			*/
			return result;
		}

		public static int FindNext(ref SearchRec aRslt)
		{
			int result = InternalFindNext(ref aRslt, ref aRslt.Name);

			/*
		  	if (result == 0)
		    	SetCodePage(Rslt.Name, DefaultRTLFileSystemCodePage);
			*/
			return result;
		}

		public static void FindClose(ref SearchRec aF) =>
			InternalFindClose(ref aF.FindHandle, ref aF.FindData);
	}
}
