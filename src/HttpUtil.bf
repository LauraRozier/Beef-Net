using System;
using System.Globalization;
using System.IO;

namespace Beef_Net
{
	public class HttpUtil
	{
		public readonly static char8[] AllASCIIChars = new .[256](
			'\x00', '\x01', '\x02', '\x03', '\x04', '\x05', '\x06', '\x07', '\x08', '\x09', '\x0a', '\x0b', '\x0c', '\x0d', '\x0e', '\x0f',
			'\x10', '\x11', '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19', '\x1a', '\x1b', '\x1c', '\x1d', '\x1e', '\x1f',
			'\x20', '\x21', '\x22', '\x23', '\x24', '\x25', '\x26', '\x27', '\x28', '\x29', '\x2a', '\x2b', '\x2c', '\x2d', '\x2e', '\x2f',
			'\x30', '\x31', '\x32', '\x33', '\x34', '\x35', '\x36', '\x37', '\x38', '\x39', '\x3a', '\x3b', '\x3c', '\x3d', '\x3e', '\x3f',
			'\x40', '\x41', '\x42', '\x43', '\x44', '\x45', '\x46', '\x47', '\x48', '\x49', '\x4a', '\x4b', '\x4c', '\x4d', '\x4e', '\x4f',
			'\x50', '\x51', '\x52', '\x53', '\x54', '\x55', '\x56', '\x57', '\x58', '\x59', '\x5a', '\x5b', '\x5c', '\x5d', '\x5e', '\x5f',
			'\x60', '\x61', '\x62', '\x63', '\x64', '\x65', '\x66', '\x67', '\x68', '\x69', '\x6a', '\x6b', '\x6c', '\x6d', '\x6e', '\x6f',
			'\x70', '\x71', '\x72', '\x73', '\x74', '\x75', '\x76', '\x77', '\x78', '\x79', '\x7a', '\x7b', '\x7c', '\x7d', '\x7e', '\x7f',
			(char8)'\x80', (char8)'\x81', (char8)'\x82', (char8)'\x83', (char8)'\x84', (char8)'\x85', (char8)'\x86', (char8)'\x87',
			(char8)'\x88', (char8)'\x89', (char8)'\x8a', (char8)'\x8b', (char8)'\x8c' ,(char8)'\x8d', (char8)'\x8e', (char8)'\x8f',
			(char8)'\x90', (char8)'\x91', (char8)'\x92', (char8)'\x93', (char8)'\x94', (char8)'\x95', (char8)'\x96', (char8)'\x97',
			(char8)'\x98', (char8)'\x99', (char8)'\x9a', (char8)'\x9b', (char8)'\x9c', (char8)'\x9d', (char8)'\x9e', (char8)'\x9f',
			(char8)'\xa0', (char8)'\xa1', (char8)'\xa2', (char8)'\xa3', (char8)'\xa4', (char8)'\xa5', (char8)'\xa6', (char8)'\xa7',
			(char8)'\xa8', (char8)'\xa9', (char8)'\xaa', (char8)'\xab', (char8)'\xac', (char8)'\xad', (char8)'\xae', (char8)'\xaf',
			(char8)'\xb0', (char8)'\xb1', (char8)'\xb2', (char8)'\xb3', (char8)'\xb4', (char8)'\xb5', (char8)'\xb6', (char8)'\xb7',
			(char8)'\xb8', (char8)'\xb9', (char8)'\xba', (char8)'\xbb', (char8)'\xbc', (char8)'\xbd', (char8)'\xbe', (char8)'\xbf',
			(char8)'\xc0', (char8)'\xc1', (char8)'\xc2', (char8)'\xc3', (char8)'\xc4', (char8)'\xc5', (char8)'\xc6', (char8)'\xc7',
			(char8)'\xc8', (char8)'\xc9', (char8)'\xca', (char8)'\xcb', (char8)'\xcc', (char8)'\xcd', (char8)'\xce', (char8)'\xcf',
			(char8)'\xd0', (char8)'\xd1', (char8)'\xd2', (char8)'\xd3', (char8)'\xd4', (char8)'\xd5', (char8)'\xd6', (char8)'\xd7',
			(char8)'\xd8', (char8)'\xd9', (char8)'\xda', (char8)'\xdb', (char8)'\xdc', (char8)'\xdd', (char8)'\xde', (char8)'\xdf',
			(char8)'\xe0', (char8)'\xe1', (char8)'\xe2', (char8)'\xe3', (char8)'\xe4', (char8)'\xe5', (char8)'\xe6', (char8)'\xe7',
			(char8)'\xe8', (char8)'\xe9', (char8)'\xea', (char8)'\xeb', (char8)'\xec', (char8)'\xed', (char8)'\xee', (char8)'\xef',
			(char8)'\xf0', (char8)'\xf1', (char8)'\xf2', (char8)'\xf3', (char8)'\xf4', (char8)'\xf5', (char8)'\xf6', (char8)'\xf7',
			(char8)'\xf8', (char8)'\xf9', (char8)'\xfa', (char8)'\xfb', (char8)'\xfc', (char8)'\xfd', (char8)'\xfe', (char8)'\xff'
		) ~ delete _;
		public readonly static char8[] HEX_LETTERS = new .[6](
			'A', 'B', 'C', 'D', 'E', 'F'
		) ~ delete _;
		public readonly static char8[] Numeric = new .[10](
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
		) ~ delete _;
		public readonly static char8[] HttpAllowedChars  = new .[72](
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'*', '@', '.', '_', '-',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'$', '!', '\'', '(', ')'
		) ~ delete _;
		public readonly static char8[] UrlAllowedChars = new .[74](
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'*', '@', '.', '_', '-',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'$', '!', '\'', '(', ')', '=', '&'
		) ~ delete _;
		public const String HttpDateFormat = "ddd, dd mmm yyyy hh:nn:ss";

		public static int Search(char8[] aArr, char8 aVal)
		{
			for (int i = 0; i < aArr.Count; i++)
				if (aArr[i] == aVal)
					return i;

			return -1;
		}

		public static uint8 HexToUInt8(char8 aChar)
		{
			if (Search(Numeric, aChar) > -1)
				return (uint8)aChar - (uint8)'0';
			else if (Search(HEX_LETTERS, aChar.ToUpper) > -1)
				return (uint8)aChar - ((uint8)'A' - 10);

			return 0;
		}

		private static void EncodeWithCharSet(StringView aStr, char8[] aCharSet, String aOutStr, StringView aSpaceString = "%20")
		{
			if (aStr.IsEmpty)
			{
				aOutStr.Set(aStr);
				return;
			}

			aOutStr.Clear();

			for (char8 char in aStr.RawChars)
			{
				if (Search(aCharSet, char) != -1)
				{
					aOutStr.Append(char);
				}
				else if (char == ' ')
				{
					aOutStr.Append(aSpaceString);
				}
				else
				{
					aOutStr.Append('%');
					((uint8)char).ToString(aOutStr, "X2", CultureInfo.InvariantCulture);
				}
			}
		}

		private static void DecodeWithSpaceChar(StringView aStr, String aOutStr, char8 aSpaceChar = 0x0)
		{
			if (aStr.IsEmpty)
			{
				aOutStr.Set(aStr);
				return;
			}

			aOutStr.Clear();
			char8[] specialChars = scope .[3]('%', aSpaceChar, 0x0);
			String tmp = scope .(aStr);
			char8* ptrSrc = tmp.CStr();
			char8* ptrNext = null;

			repeat
			{
				while (Search(specialChars, *ptrSrc) == -1)
					aOutStr.Append(*ptrSrc++);

				if (ptrSrc[0] == '%' && ptrSrc[1] != 0x0 && ptrSrc[2] != 0x0)
				{
					aOutStr.Append((char8)((HexToNum(ptrSrc[1]) << 4) + HexToNum(ptrSrc[2])));
					ptrNext = ptrSrc += 3;
				}
				else if (aSpaceChar != 0x0 && ptrSrc[0] == aSpaceChar)
				{
					aOutStr.Append(' ');
					ptrNext = ++ptrSrc; // Should be equal to `ptrNext = ptrPos += 1`
				}
				else
				{
					ptrNext = null;
				}
			}
			while (ptrNext != null);
		}

		public static bool TryHttpDateStrToDateTime(char8* aDateStr, ref DateTime aDest)
		{
			int year, month, day;
			int[3] timeArr = .(0, 0, 0);
			String tmpStr = scope .();
			String tmpCmpStr = scope .();
			String tmpDateStr = scope .(aDateStr);

			if (tmpDateStr.Length < HttpDateFormat.Length + 4)
				return false;

			// skip redundant short day string
			tmpDateStr.Remove(0, 5);

			// day
			if (tmpDateStr[2] == ' ')
			{
				if (Int.Parse(tmpDateStr.Substring(0, 2)) case .Ok(let val))
					day = val;
				else
					return false;

				tmpDateStr.Remove(0, 3);
			}
			else
			{
				return false;
			}

			// month
			month = 1;
			tmpStr.Set(tmpDateStr.Substring(0, 3));

			while (true)
			{
				tmpCmpStr.Clear();
				DateTimeFormatInfo.InvariantInfo.GetAbbreviatedMonthName(month, tmpCmpStr);

				if (String.Compare(tmpStr, tmpCmpStr, true) == 0)
					break;

				month++;

				if (month == 13)
					return false;
			}

			tmpDateStr.Remove(0, 4);
			
			// year
			if (tmpCmpStr[4] == ' ')
			{
				if (Int.Parse(tmpDateStr.Substring(0, 4)) case .Ok(let val))
					year = val;
				else
					return false;

				tmpDateStr.Remove(0, 5);
			}
			else
			{
				return false;
			}

			// hour, minute, second
			for (int i = 0; i <= timeArr.Count; i++)
			{
				if (Int.Parse(tmpDateStr.Substring(0, 2)) case .Ok(let val))
					timeArr[i] = val;
				else
					return false;

				tmpDateStr.Remove(0, 3);
			}
			
			aDest = .(year, month, day, timeArr[0], timeArr[1], timeArr[2], 0);
			return true;
		}

		public static bool SeparatePath(StringView aInPath, String aOutExtraPath, int32 aMode, SearchRec* aSearchRec = null)
		{
			var aSearchRec;
			SearchRec lSearchRec = .();

			if (aSearchRec == null)
				aSearchRec = &lSearchRec;

			aOutExtraPath.Set("");

			if (aInPath.Length <= 2)
				return false;

			String tmpPath = scope .(aInPath);

			if (tmpPath[tmpPath.Length - 1] == Path.DirectorySeparatorChar)
				tmpPath.RemoveFromEnd(1);

			bool result = false;
			int pos = 0;

			while (true)
			{
				result = FileUtils.FindFirst(tmpPath, aMode, ref *aSearchRec) == 0;
				FileUtils.FindClose(ref *aSearchRec);

				if (result)
				{
					aOutExtraPath.Set(aInPath.Substring(tmpPath.Length, aInPath.Length - tmpPath.Length));
					break;
				}

				pos = tmpPath.LastIndexOf(Path.DirectorySeparatorChar);

				if (pos > 0)
					tmpPath.RemoveToEnd(pos);
				else
				  	break;
			}

			return result;
		}

		public static bool CheckPermission(StringView aDocument)
		{
			int pos = 0;

			while (true)
			{
				pos = aDocument.IndexOf('/', pos);

				if (pos == -1)
					return true;

				if (aDocument[pos + 1] == '.' && aDocument[pos + 2] == '.' && (aDocument[pos + 3] == '/' || aDocument[pos + 3] == 0x00))
					return false;

				pos++;
			}
		}

		// Direct port, not sure how this is correct but... sure?
		public static uint8 HexToNum(char8 aChar)
		{
			if ('0' <= aChar && aChar <= '9')
			  	return ((uint8)aChar) - ((uint8)'0');
			else if ('A' <= aChar && aChar <= 'F')
			  	return ((uint8)aChar) - (((uint8)'A') - 10);
			else if ('a' <= aChar && aChar <= 'f')
			  	return ((uint8)aChar) - (((uint8)'a') - 10);
			else
			  	return 0;
		}

		public static void HttpEncode(StringView aStr, String aOutStr) =>
			EncodeWithCharSet(aStr, HttpAllowedChars, aOutStr);

		public static void HttpDecode(StringView aStr, String aOutStr) =>
			DecodeWithSpaceChar(aStr, aOutStr, '+');

		public static void UrlEncode(StringView aStr, String aOutStr, bool aInQueryString = false) =>
			EncodeWithCharSet(aStr, UrlAllowedChars, aOutStr, aInQueryString ? "+" : "%20");

		public static void UrlDecode(StringView aStr, String aOutStr, bool aInQueryString = false) =>
			DecodeWithSpaceChar(aStr, aOutStr, aInQueryString ? '+' : 0x0);

		public static void ComposeUrl(StringView aHost, StringView aUri, uint16 aPort, String aOutStr)
		{
			aOutStr.Clear();
			aOutStr.AppendF("{0}{1}:{2}", aHost, aUri, aPort);
		}

		/// Decompose URL and return TRUE when the protocol is HTTPS, else return FALSE
		public static bool DecomposeUrl(StringView aURL, String aOutHost, String aOutURI, out uint16 aOutPort)
		{
			URI uri = scope .();
			URI.Parse(aURL, "http", 0, uri); // default to 0 so we can set SSL port
			bool result = uri.Protocol.Equals("https", .InvariantCultureIgnoreCase);
			aOutHost.Set(uri.Host);

			String tmp = scope .(uri.Path, uri.Document);
			EncodeWithCharSet(tmp, AllASCIIChars, aOutURI);

			if (aOutURI.Length == 0)
				aOutURI.Append('/');

			if (!uri.Params.IsWhiteSpace)
				aOutURI.AppendF("?{0}", uri.Params);

			aOutPort = uri.Port;

			if (aOutPort == 0)
				aOutPort = result
					? 443 // default https/ssl port
					: 80; // default http port

			return result;
		}
	}
}
