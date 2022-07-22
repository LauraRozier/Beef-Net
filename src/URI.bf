using System;
using System.Globalization;

namespace Beef_Net
{
	public class URI
	{
		public readonly static char8[] GenDelims = new .[7](
			':', '/', '?', '#', '[', ']', '@'
		) ~ delete _;
		public readonly static char8[] SubDelims = new .[11](
			'!', '$', '&', '\'', '(', ')', '*', '+', ',', ';', '='
		) ~ delete _;
		public readonly static char8[] Alpha = new .[52](
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
		) ~ delete _;
		public readonly static char8[] Numeric = new .[10](
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
		) ~ delete _;
		public readonly static char8[] Unreserved = new .[66]( // ALPHA + DIGIT + ['-', '.', '_', '~']
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'-', '.', '_', '~'
		) ~ delete _;
		public readonly static char8[] ValidPathChars = new .[80]( // Unreserved + SubDelims + ['@', ':', '/']
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'-', '.', '_', '~',
			'!', '$', '&', '\'', '(', ')', '*', '+', ',', ';', '=',
			'@', ':', '/'
		) ~ delete _;
		public readonly static char8[] AbsoluteUriChars = new .[65](
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'+', '-', '.'
		) ~ delete _;

		public String Protocol = new .() ~ delete _;
		public String Username = new .() ~ delete _;
		public String Password = new .() ~ delete _;
		public String Host = new .() ~ delete _;
		public uint16 Port = 0;
		public String Path = new .() ~ delete _;
		public String Document = new .() ~ delete _;
		public String Params = new .() ~ delete _;
		public String Bookmark = new .() ~ delete _;
		public bool HasAuthority = true;

		private static void Escape(StringView aStr, char8[] aAllowed, String aOutStr)
		{
			int l = aStr.Length;

			for (int i = 0; i < aStr.Length; i++)
				if (HttpUtil.Search(aAllowed, aStr[i]) < 0)
					l += 2;

			if (l == aStr.Length)
			{
				aOutStr.Set(aStr);
				return;
			}

			for (char8 char in aStr.RawChars)
			{
				if (HttpUtil.Search(aAllowed, char) < 0)
				{
					aOutStr.Append('%');
					((uint8)char).ToString(aOutStr, "X2", CultureInfo.InvariantCulture);
				}
				else
				{
					aOutStr.Append(char);
				}
			}
		}

		private static void Unescape(StringView aStr, String aOutStr)
		{
			aOutStr.Clear();
			aOutStr.PrepareBuffer(aStr.Length);

			int i = 0;
			int realLen = 0;
			char8* ptr = aOutStr.Ptr; // Use the pointer to prevent superfluous method calls

			while (i < aStr.Length)
			{
				if (aStr[i] == '%')
				{
					ptr[realLen++] = (char8)(HttpUtil.HexToUInt8(aStr[i + 1]) << 4 | HttpUtil.HexToUInt8(aStr[i + 2]));
					i += 3;
				}
				else
				{
					ptr[realLen++] = aStr[i++];
				}
			}

			aOutStr.RemoveFromEnd(aOutStr.Length - realLen);
		}

		private static void RemoveDotSegments(ref String aStr)
		{
			int prev = aStr.IndexOf('/');
			int cur = 0;

			while (prev > -1 && prev < aStr.Length - 1)
			{
				cur = prev + 1;

				while (cur < aStr.Length && aStr[cur] != '/')
					cur++;

				if (cur - prev == 2 && aStr[prev + 1] == '.')
				{
					aStr.Remove(prev + 1, 2);
				}
				else if (cur - prev == 3 && aStr[prev + 1] == '.' && aStr[prev + 2] == '.')
				{
					while (prev > 1 && aStr[prev - 1] != '/')
						prev--;

					if (prev > 1)
						prev--;

					aStr.Remove(prev + 1, cur - prev);
				}
				else
				{
					prev = cur;
				}
			}
		}

		public void Encode(String aOutStr)
		{
			// ! If there is no scheme then the first colon in the path should be escaped
			aOutStr.Clear();

			if (Protocol.Length > 0)
			{
				Protocol.ToLower();
				aOutStr.AppendF("{0}:", Protocol);
			}

			if (HasAuthority)
			{
				aOutStr.Append("//");

				if (Username.Length > 0)
				{
					aOutStr.Append(Username);

					if (Password.Length > 0)
						aOutStr.AppendF(":{0}", Password);

					aOutStr.Append('@');
				}

				aOutStr.Append(Host);
			}

			if (Port != 0)
				aOutStr.AppendF(":{0}", Port);

			String tmp = scope .();
			Escape(Path, ValidPathChars, tmp);
			aOutStr.Append(tmp);

			if (Document.Length > 0)
			{
				if (Path.Length > 0 && (aOutStr.Length == 0 || !aOutStr.EndsWith('/')))
					aOutStr.Append('/');

				tmp.Clear();
				Escape(Document, ValidPathChars, tmp);
				aOutStr.Append(tmp);
			}

			if (Params.Length > 0)
			{
				tmp.Clear();
				Escape(Params, ValidPathChars, tmp);
				aOutStr.AppendF("?{0}", tmp);
			}

			if (Bookmark.Length > 0)
			{
				tmp.Clear();
				Escape(Bookmark, ValidPathChars, tmp);
				aOutStr.AppendF("#{0}", tmp);
			}
		}

		public static void Parse(StringView aUri, URI aOutUri, bool aIndDecode = true) =>
			Parse(aUri, "", 0, aOutUri, aIndDecode);

		public static void Parse(StringView aUri, StringView aDefaultProtocol, uint16 aDefaultPort, URI aOutUri, bool aIndDecode = true)
		{
			aOutUri.Protocol.Set(aDefaultProtocol);
			aOutUri.Protocol.ToLower();
			aOutUri.Port = aDefaultPort;
			
			String tmp = scope .();
			String authority = scope .();
			String str = scope .(aUri);
			int i = 0;

			// Extract scheme
			for (i = 0; i < str.Length; i++)
			{
				if (str[i] == ':')
				{
					aOutUri.Protocol.Set(str.Substring(0, i));
					str.Remove(0, i + 1);
					break;
				}
				else if (!((i == 0 && HttpUtil.Search(Alpha, str[i]) > -1) || HttpUtil.Search(AbsoluteUriChars, str[i]) > -1))
				{
					break;
				}
			}

			// Extract the bookmark
			i = str.LastIndexOf('#');

			if (i > -1)
			{
				aOutUri.Bookmark.Set(str.Substring(i + 1));

				if (aIndDecode)
				{
					tmp.Clear();
					Unescape(aOutUri.Bookmark, tmp);
					aOutUri.Bookmark.Set(tmp);
				}

				str.RemoveToEnd(i);
			}

			// Extract the params
			i = str.LastIndexOf('?');

			if (i > -1)
			{
				aOutUri.Params.Set(str.Substring(i + 1));

				if (aIndDecode)
				{
					tmp.Clear();
					Unescape(aOutUri.Params, tmp);
					aOutUri.Params.Set(tmp);
				}

				str.RemoveToEnd(i);
			}

			// Extract authority
			if (str.Length > 1 && str[0] == '/' && str[1] == '/')
			{
				i = 2;

				while (i < str.Length && str[i] != '/')
					i++;

				authority.Set(str.Substring(2, i - 2));
				str.Remove(0, i);
				aOutUri.HasAuthority = true; // even if Authority is empty
			}
			else
			{
				aOutUri.HasAuthority = false;
			}

			// Now `str` is 'hier-part' per RFC3986 ; Extract the document name (nasty...)
			for (i = str.Length - 1; i >= 0; i--)
			{
				if (str[i] == '/')
				{
					aOutUri.Document.Set(str.Substring(i));

					if (aIndDecode)
					{
						tmp.Clear();
						Unescape(aOutUri.Document, tmp);
						aOutUri.Document.Set(tmp);
					}

					if (aOutUri.Document != "." && aOutUri.Document != "..")
						str.RemoveToEnd(i);
					else
						aOutUri.Document.Clear();

					break;
				}
				else if (str[i] == ':')
				{
					break;
				}
				else if (i == 0)
				{
					aOutUri.Document.Set(str);

					if (aIndDecode)
					{
						tmp.Clear();
						Unescape(aOutUri.Document, tmp);
						aOutUri.Document.Set(tmp);
					}

					if (aOutUri.Document != "." && aOutUri.Document != "..")
						str.Clear();
					else
						aOutUri.Document.Clear();
				}
			}

			// Everything left is a path
			aOutUri.Path.Set(str);

			if (aIndDecode)
			{
				tmp.Clear();
				Unescape(aOutUri.Path, tmp);
				aOutUri.Path.Set(tmp);
			}

			// Extract the port number
			/* i := LastDelimiter(':@', Authority); */
			i = authority.LastIndexOf(':');
			int j = authority.LastIndexOf('@');

			// Get the index of the last character that matches either `:` or `@`
			if (i < j)
				i = j;

			if (i > -1 && i < authority.Length && authority[i] == ':')
			{
				bool validPort = true;

				for (j = i + 1; j < authority.Length; j++)
					if (HttpUtil.Search(Numeric, authority[j]) == -1)
					{
						validPort = false;
						break;
					}

				if (validPort)
				{
					if (UInt32.Parse(authority.Substring(i + 1)) case .Ok(let val))
						aOutUri.Port = (uint16)val;

					authority.RemoveToEnd(i);
				}
			}

			if (aOutUri.Port == 0)
			{
				if (aOutUri.Protocol.Equals("ftp", .OrdinalIgnoreCase) || aOutUri.Protocol.Equals("ftps", .OrdinalIgnoreCase))
					aOutUri.Port = 21;
				else if (
					aOutUri.Protocol.Equals("ssh", .OrdinalIgnoreCase) ||
					aOutUri.Protocol.Equals("sftp", .OrdinalIgnoreCase) ||
					aOutUri.Protocol.Equals("rsync", .OrdinalIgnoreCase)
				)
					aOutUri.Port = 22;
				else if (aOutUri.Protocol.Equals("http", .OrdinalIgnoreCase))
					aOutUri.Port = 80;
				else if (aOutUri.Protocol.Equals("pop3", .OrdinalIgnoreCase))
					aOutUri.Port = 110;
				else if (aOutUri.Protocol.Equals("imap", .OrdinalIgnoreCase))
					aOutUri.Port = 143;
				else if (aOutUri.Protocol.Equals("ldap", .OrdinalIgnoreCase))
					aOutUri.Port = 389;
				else if (aOutUri.Protocol.Equals("https", .OrdinalIgnoreCase))
					aOutUri.Port = 443;
				else if (aOutUri.Protocol.Equals("afp", .OrdinalIgnoreCase))
					aOutUri.Port = 548;
				else if (aOutUri.Protocol.Equals("ldap", .OrdinalIgnoreCase))
					aOutUri.Port = 636;
				else if (aOutUri.Protocol.Equals("cvs", .OrdinalIgnoreCase))
					aOutUri.Port = 2401;
				else if (aOutUri.Protocol.Equals("svn", .OrdinalIgnoreCase))
					aOutUri.Port = 3690;
				else if (aOutUri.Protocol.Equals("git", .OrdinalIgnoreCase))
					aOutUri.Port = 9418;
			}

			// Extract the hostname
			i = authority.IndexOf('@');

			if (i > -1)
			{
				aOutUri.Host.Set(authority.Substring(i + 1));
				authority.RemoveToEnd(i);

			    // Extract username and password
				if (authority.Length > 0)
				{
					i = authority.IndexOf(':');

					if (i == 0)
					{
						aOutUri.Username.Set(authority);
					}
					else
					{
						aOutUri.Username.Set(authority.Substring(0, i));
						aOutUri.Password.Set(authority.Substring(i + 1));
					}
				}
			}
			else
			{
				aOutUri.Host.Set(authority);
			}
		}

		public static bool ResolveRelativeUri(StringView aBaseUri, StringView aRelUri, String aOutUri)
		{
			aOutUri.Clear();

			URI baseUri = scope .();
			URI relUri =  scope .();
			Parse(aBaseUri, baseUri);
			Parse(aRelUri, relUri);

			bool result = (!baseUri.Protocol.IsEmpty) || (!relUri.Protocol.IsEmpty);

			if (!result)
				return result;

			if (relUri.Path.IsEmpty && relUri.Document.IsEmpty)
			{
				if (relUri.Params.IsEmpty)
				  	baseUri.Params.Set(relUri.Params);

				baseUri.Bookmark.Set(relUri.Bookmark);
				baseUri.Encode(aOutUri);
				return result;
			}

		    if (!relUri.Protocol.IsEmpty) // aRelUri is absolute - return it...
			{
				aOutUri.Set(aRelUri);
				return result;
			}

			// Inherit protocol
			relUri.Protocol.Set(baseUri.Protocol);

			if (relUri.Host.IsEmpty) // TODO: or "not HasAuthority"?
			{
				// Inherit Authority (host, port, username, password)
				relUri.Host.Set(baseUri.Host);
				relUri.Port = baseUri.Port;
				relUri.Username.Set(baseUri.Username);
				relUri.Password.Set(baseUri.Password);
				relUri.HasAuthority = baseUri.HasAuthority;

				if (relUri.Path.IsEmpty || relUri.Path[1] != '/') // path is empty or relative
				{
					String tmp = scope .(baseUri.Path);
					tmp.Append(relUri.Path);
				}

				RemoveDotSegments(ref relUri.Path);
			}

			// URI.Encode percent-encodes the result, and that's good
			relUri.Encode(aOutUri);
			return result;
		}

		public static bool UriToFilename(StringView aUri, String aOutFilename)
		{
			bool result = false;
			URI u = scope .();
			Parse(aUri, u);

			if (u.Protocol.Equals("file", .OrdinalIgnoreCase))
			{
				if (u.Path.Length > 2 && u.Path[0] == '/' && u.Path[2] == ':')
					aOutFilename.Set(u.Path.Substring(1)); // in case of /C:/path/file.ext we strip the / to get a valid file name
				else
					aOutFilename.Set(u.Path);

				aOutFilename.Append(u.Document);
				result = true;
			}
			else
			{
				if (u.Protocol.IsEmpty) // fire and pray?
				{
					aOutFilename.Set(u.Path);
					aOutFilename.Append(u.Document);
					result = true;
				}
			}

			if (IO.Path.DirectorySeparatorChar != '/')
				aOutFilename.Replace('/', IO.Path.DirectorySeparatorChar);

			return result;
		}

		public static void FilenameToUri(StringView aFilename, String aOutStr, bool aIndEncode = true)
		{
			bool isAbsPath = ((!aFilename.IsEmpty) && aFilename[0] == IO.Path.DirectorySeparatorChar) ||
				(aFilename.Length > 2 && HttpUtil.Search(Alpha, aFilename[0]) != -1 && aFilename[1] == ':');

			aOutStr.Set("file:");

			if (isAbsPath)
				aOutStr.Append(aFilename[0] == IO.Path.DirectorySeparatorChar ? "//" : "///");

			String filenamePart = scope .(aFilename);

			if (IO.Path.DirectorySeparatorChar != '/')
				filenamePart.Replace('\\', '/');

			if (aIndEncode)
			{
				String tmp = scope .();
				Escape(filenamePart, ValidPathChars, tmp);
				filenamePart.Set(tmp);
			}

			aOutStr.Append(filenamePart);
		}

		public static bool IsAbsoluteUri(StringView aUriReference)
		{
			for (int i = 0; i < aUriReference.Length; i++)
			{
				if (aUriReference[i] == ':')
					return true;
				else if (!((i == 0 && HttpUtil.Search(Alpha, aUriReference[i]) >= 0) || HttpUtil.Search(AbsoluteUriChars, aUriReference[i]) >= 0))
					break;
			}

			return false;
		}
	}
}
