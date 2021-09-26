using System;
using System.Globalization;
using System.IO;

namespace Beef_Net
{
	public class URI
	{
		public readonly static char8[] GenDelims = new char8[7] (
			':', '/', '?', '#', '[', ']', '@'
		) ~ delete _;
		public readonly static char8[] SubDelims = new char8[11] (
			'!', '$', '&', '\'', '(', ')', '*', '+', ',', ';', '='
		) ~ delete _;
		public readonly static char8[] ALPHA = new char8[52] (
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
		) ~ delete _;
		public readonly static char8[] Unreserved = new char8[66] ( // ALPHA + DIGIT + ['-', '.', '_', '~']
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'-', '.', '_', '~'
		) ~ delete _;
		public readonly static char8[] ValidPathChars = new char8[80] ( // Unreserved + SubDelims + ['@', ':', '/']
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'-', '.', '_', '~',
			'!', '$', '&', '\'', '(', ')', '*', '+', ',', ';', '=',
			'@', ':', '/'
		) ~ delete _;
		public readonly static char8[] AbsoluteUriChars = new char8[65] (
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'+', '-', '.'
		) ~ delete _;

		public readonly String Protocol = new .() ~ delete _;
		public readonly String Username = new .() ~ delete _;
		public readonly String Password = new .() ~ delete _;
		public readonly String Host = new .() ~ delete _;
		public readonly uint16 Port = 0;
		public readonly String Path = new .() ~ delete _;
		public readonly String Document = new .() ~ delete _;
		public readonly String Params = new .() ~ delete _;
		public readonly String Bookmark = new .() ~ delete _;
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

			aOutStr.Reserve(l);
			aOutStr.Length = l;
			char8* outPtr = aOutStr.Ptr;
			String tmp = scope .();

			for (int i = 0; i < aStr.Length; i++)
			{
				if (HttpUtil.Search(aAllowed, aStr[i]) < 0)
				{
					tmp.Clear();
					tmp.AppendF("{0:x2}", (uint8)aStr[i]);
					*outPtr++ = '%';
					*outPtr++ = tmp[0];
					*outPtr++ = tmp[1];
				}
				else
				{
					*outPtr++ = aStr[i];
				}
			}
		}

		private static void Unescape(StringView aStr, String aOutStr)
		{
			aOutStr.Clear();
			aOutStr.Reserve(aStr.Length);
			aOutStr.Length = aStr.Length;

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

		public static URI Parse(StringView aUri, bool aIndDecode = true) =>
			Parse(aUri, "", 0, aIndDecode);

		public static URI Parse(StringView aUri, StringView aDefaultProtocol, uint16 aDefaultPort, bool aIndDecode = true)
		{
			/*
			var
			  s, Authority: String;
			  i,j: Integer;
			  PortValid: Boolean;
			  
			begin
			  Result:=Default(TURI);
			  Result.Protocol := LowerCase(DefaultProtocol);
			  Result.Port := DefaultPort;

			  s := URI;

			  // Extract scheme

			  for i := 1 to Length(s) do
			    if s[i] = ':' then
			    begin
			      Result.Protocol := Copy(s, 1, i - 1);
			      s := Copy(s, i + 1, MaxInt);
			      break;
			    end
			    else
			      if not (((i=1) and (s[i] in ALPHA)) or (s[i] in ALPHA + DIGIT + ['+', '-', '.'])) then
			        break;

			  // Extract the bookmark

			  i := LastDelimiter('#', s);
			  if i > 0 then
			  begin
			    Result.Bookmark := Copy(s, i + 1, MaxInt);
			    if Decode then
			      Result.Bookmark:=Unescape(Result.Bookmark);
			    s := Copy(s, 1, i - 1);
			  end;

			  // Extract the params

			  i := LastDelimiter('?', s);
			  if i > 0 then
			  begin
			    Result.Params := Copy(s, i + 1, MaxInt);
			    if Decode then
			      Result.Params:=Unescape(Result.Params);
			    s := Copy(s, 1, i - 1);
			  end;

			  // extract authority

			  if (Length(s) > 1) and (s[1] = '/') and (s[2] = '/') then
			  begin
			    i := 3;
			    while (i <= Length(s)) and (s[i] <> '/') do
			      Inc(i);
			    Authority := Copy(s, 3, i-3);
			    s := Copy(s, i, MaxInt);
			    Result.HasAuthority := True;    // even if Authority is empty
			  end
			  else
			  begin
			    Result.HasAuthority := False;
			    Authority := '';
			  end;

			  // now s is 'hier-part' per RFC3986
			  // Extract the document name (nasty...)

			  for i := Length(s) downto 1 do
			    if s[i] = '/' then
			    begin
			      Result.Document :=Copy(s, i + 1, Length(s));
			      if Decode then
			        Result.Document:=Unescape(Result.Document);
			      if (Result.Document <> '.') and (Result.Document <> '..') then
			        s := Copy(s, 1, i)
			      else
			        Result.Document := '';
			      break;
			    end else if s[i] = ':' then
			      break
			    else if i = 1 then
			    begin
			      Result.Document :=s;
			      if Decode then
			        Result.Document:=Unescape(Result.Document);
			      if (Result.Document <> '.') and (Result.Document <> '..') then
			        s := ''
			      else
			        Result.Document := '';
			      // break - not needed, last iteration
			    end;

			  // Everything left is a path

			  Result.Path := s;
			  if Decode then
			    Result.Path:=Unescape(Result.Path);

			  // Extract the port number

			  i := LastDelimiter(':@', Authority);
			  if (i > 0) and (i < Length(Authority)) and (Authority[i] = ':') then
			  begin
			    PortValid := true;
			    for j:=i+1 to Length(Authority) do
			      if not (Authority[j] in ['0'..'9']) then
			      begin
			        PortValid := false;
			        break;
			      end;
			    if PortValid then
			    begin
			      Result.Port := StrToInt(Copy(Authority, i + 1, MaxInt));
			      Authority := Copy(Authority, 1, i - 1);
			    end;
			  end;

			  // Extract the hostname

			  i := Pos('@', Authority);
			  if i > 0 then
			  begin
			    Result.Host := Copy(Authority, i+1, MaxInt);
			    Delete(Authority, i, MaxInt);

			    // Extract username and password
			    if Length(Authority) > 0 then
			    begin
			      i := Pos(':', Authority);
			      if i = 0 then
			        Result.Username := Authority
			      else
			      begin
			        Result.Username := Copy(Authority, 1, i - 1);
			        Result.Password := Copy(Authority, i + 1, MaxInt);
			      end;
			    end;
			  end
			  else
			    Result.Host := Authority;
			end;
			*/
			return new URI();
		}

		public static bool ResolveRelativeUri(StringView aBaseUri, StringView aRelUri, String aOutUri)
		{
			/*
			var
			  Base, Rel: TUri;
			begin
			  Base := ParseUri(BaseUri);
			  Rel := ParseUri(RelUri);

			  Result := (Base.Protocol <> '') or (Rel.Protocol <> '');
			  if not Result then
			    Exit;
			  with Rel do
			  begin
			    if (Path = '') and (Document = '') then
			    begin
			      if (Protocol = '') and (Host = '') then
			      begin
			        if Params <> '' then
			          Base.Params := Params;
			        Base.Bookmark := Bookmark;
			        ResultUri := EncodeUri(Base);
			        Exit;
			      end;
			    end;
			    if (Protocol <> '') then  // RelURI is absolute - return it...
			    begin
			      ResultUri := RelUri;
			      Exit;
			    end;
			    // Inherit protocol
			    Protocol := Base.Protocol;
			    if (Host = '') then   // TODO: or "not HasAuthority"?
			    begin
			      // Inherit Authority (host, port, username, password)
			      Host := Base.Host;
			      Port := Base.Port;
			      Username := Base.Username;
			      Password := Base.Password;
			      HasAuthority := Base.HasAuthority;
			      if (Path = '') or (Path[1] <> '/') then  // path is empty or relative
			        Path := Base.Path + Path;
			      RemoveDotSegments(Path);
			    end;
			  end; // with
			  
			  // EncodeUri percent-encodes the result, and that's good
			  ResultUri := EncodeUri(Rel);
			end;
			*/
			return true;
		}

		public static bool UriToFilename(StringView aUri, String aOutFilename)
		{
			/*
			var
			  U: TURI;
			  I: Integer;
			begin
			  Result := False;
			  U := ParseURI(URI);
			  if SameText(U.Protocol, 'file') then
			  begin
			    if (Length(U.Path) > 2) and (U.Path[1] = '/') and (U.Path[3] = ':') then
			      Filename := Copy(U.Path, 2, MaxInt)
			    else
			      Filename := U.Path;
			    Filename := Filename + U.Document;
			    Result := True;
			  end
			  else
			    if U.Protocol = '' then  // fire and pray?
			    begin
			      Filename := U.Path + U.Document;
			      Result := True;
			    end;
			  if PathDelim <> '/' then
			  begin
			    I := Pos('/', Filename);
			    while I > 0 do
			    begin
			      Filename[I] := PathDelim;
			      I := Pos('/', Filename);
			    end;
			  end;
			end;
			*/
			return true;
		}

		public static void FilenameToUri(StringView aFilename, String aOutStr, bool aIndEncode = true)
		{
			/*
			var
			  I: Integer;
			  IsAbsFilename: Boolean;
			  FilenamePart: string;
			begin
			  IsAbsFilename := ((Filename <> '') and (Filename[1] = PathDelim)) or
			    ((Length(Filename) > 2) and (Filename[1] in ['A'..'Z', 'a'..'z']) and (Filename[2] = ':'));

			  Result := 'file:';
			  if IsAbsFilename then
			  begin
			    if Filename[1] <> PathDelim then
			      Result := Result + '///'
			    else
			      Result := Result + '//';
			  end;

			  FilenamePart := Filename;
			  { unreachable code warning is ok here }
			  if PathDelim <> '/' then
			  begin
			    I := Pos(PathDelim, FilenamePart);
			    while I <> 0 do
			    begin
			      FilenamePart[I] := '/';
			      I := Pos(PathDelim, FilenamePart);
			    end;
			  end;
			  if Encode then
			    FilenamePart := Escape(FilenamePart, ValidPathChars);

			  Result := Result + FilenamePart;
			end;
			*/
		}

		public static bool IsAbsoluteUri(StringView aUriReference)
		{
			for (int i = 0; i < aUriReference.Length; i++)
			{
				if (aUriReference[i] == ':')
					return true;
				else if (!((i == 0 && HttpUtil.Search(ALPHA, aUriReference[i]) >= 0) || HttpUtil.Search(AbsoluteUriChars, aUriReference[i]) >= 0))
					break;
			}

			return false;
		}
	}

	class HttpUtil
	{
		public readonly static char8[] AllASCIIChars = new .[256] (
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
		public readonly static char8[] HEX_LETTERS = new char8[6] (
			'A', 'B', 'C', 'D', 'E', 'F'
		) ~ delete _;
		public readonly static char8[] DIGIT = new char8[10] (
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
		) ~ delete _;
		public readonly static char8[] HTTPAllowedChars  = new .[72] (
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'*', '@', '.', '_', '-',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'$', '!', '\'', '(', ')'
		) ~ delete _;
		public readonly static char8[] URLAllowedChars = new .[74] (
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'*', '@', '.', '_', '-',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'$', '!', '\'', '(', ')', '=', '&'
		) ~ delete _;
		public readonly static String HTTPDateFormat = "ddd, dd mmm yyyy hh:nn:ss";

		public static int Search(char8[] aArr, char8 aVal)
		{
			for (int i = 0; i < aArr.Count; i++)
				if (aArr[i] == aVal)
					return i;

			return -1;
		}

		public static uint8 HexToUInt8(char8 aChar)
		{
			if (Search(DIGIT, aChar) > -1)
				return (uint8)aChar - (uint8)'0';
			else if (Search(HEX_LETTERS, aChar.ToUpper) > -1)
				return (uint8)aChar - ((uint8)'A' - 10);

			return 0;
		}

		private static void EncodeWithCharSet(StringView aStr, char8[] aCharSet, String aOutStr, StringView aSpaceString = "%20")
		{
			/*
			var
			  src, srcend, dest: pchar;
			  hex: string[2];
			  i, n, len: integer;
			begin
			  len := Length(AStr);
			  if len = 0 then
			    Exit(aStr);

			  n := Length(SpaceString);
			  SetLength(Result, len*3); // Worst case scenario
			  if len = 0 then
			    exit;
			  dest := pchar(Result);
			  src := pchar(AStr);
			  srcend := src + len;
			  while src < srcend do
			  begin
			    if src^ in aCharSet then
			      dest^ := src^
			    else if src^ = ' ' then begin
			      for i := 1 to n do begin
			        dest^ := SpaceString[i];
			        if i < n then
			          inc(dest);
			      end;
			    end else begin
			      dest^ := '%';
			      inc(dest);
			      hex := HexStr(Ord(src^),2);
			      dest^ := hex[1];
			      inc(dest);
			      dest^ := hex[2];
			    end;
			    inc(dest);
			    inc(src);
			  end;
			  SetLength(Result, dest - pchar(Result));
			end;
			*/
		}

		private static void DecodeWithSpaceChar(StringView aStr, String aOutStr, char8 aSpaceChar = 0x0)
		{
			/*
			var
			  lStr, lPos, lNext, lDest: pchar;
			begin
			  if Length(aStr) = 0 then
			    Exit(aStr);

			  Result := aStr; // this is just a re-assign of pointer, should be fast
			  lDest := @Result[1]; // let's do it pointer-wise
			  lStr := lDest;
			  repeat
			    lPos := lStr;
			    while not (lPos^ in ['%', SpaceChar, #0]) do
			      Inc(lPos);
			    if (lPos[0]='%') and (lPos[1] <> #0) and (lPos[2] <> #0) then
			    begin
			      lPos^ := char((HexToNum(lPos[1]) shl 4) + HexToNum(lPos[2]));
			      lNext := lPos+3;
			    end else if ((SpaceChar <> #0) and (lPos[0] = SpaceChar)) then
			    begin
			      lPos^ := ' ';
			      lNext := lPos+1;
			    end else
			      lNext := nil;
			    Inc(lPos);
			    if lDest <> lStr then
			      Move(lStr^, lDest^, lPos-lStr);
			    Inc(lDest, lPos-lStr);
			    lStr := lNext;
			  until lNext = nil;
			  SetLength(Result, lDest - pchar(Result) - 1);
			end;
			*/
		}

		public static bool TryHTTPDateStrToDateTime(char8* aDateStr, ref DateTime aDest)
		{
			int year, month, day;
			int[3] timeArr = .(0, 0, 0);
			Result<int, Int.ParseError> parseRes;
			String tmpStr = scope .();
			String tmpCmpStr = scope .();
			String tmpDateStr = scope .(aDateStr);

			if (tmpDateStr.Length < HTTPDateFormat.Length + 4)
				return false;

			// skip redundant short day string
			tmpDateStr.Remove(0, 5);

			// day
			if (tmpDateStr[2] == ' ')
			{
				parseRes = Int.Parse(tmpDateStr.Substring(0, 2));

				if (parseRes case .Err)
					return false;

				day = parseRes.Value;
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
				parseRes = Int.Parse(tmpDateStr.Substring(0, 4));

				if (parseRes case .Err)
					return false;

				year = parseRes.Value;
				tmpDateStr.Remove(0, 5);
			}
			else
			{
				return false;
			}

			// hour, minute, second
			for (int i = 0; i <= timeArr.Count; i++)
			{
				parseRes = Int.Parse(tmpDateStr.Substring(0, 2));

				if (parseRes case .Err)
					return false;

				timeArr[i] = parseRes.Value;
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

		public static void HTTPEncode(StringView aStr, String aOutStr) =>
			EncodeWithCharSet(aStr, HTTPAllowedChars, aOutStr);

		public static void HTTPDecode(StringView aStr, String aOutStr) =>
			DecodeWithSpaceChar(aStr, aOutStr, '+');

		public static void URLEncode(StringView aStr, String aOutStr, bool aInQueryString = false) =>
			EncodeWithCharSet(aStr, URLAllowedChars, aOutStr, aInQueryString ? "+" : "%20");

		public static void URLDecode(StringView aStr, String aOutStr, bool aInQueryString = false) =>
			DecodeWithSpaceChar(aStr, aOutStr, aInQueryString ? '+' : 0x0);

		public static void ComposeURL(StringView aHost, StringView aUri, uint16 aPort, String aOutStr)
		{
			aOutStr.Clear();
			aOutStr.AppendF("{0}{1}:{2}", aHost, aUri, aPort);
		}

		/// Decompose URL and return TRUE when the protocol is HTTPS, else return FALSE
		public static bool DecomposeURL(StringView aURL, String aOutHost, String aOutURI, out uint16 aOutPort)
		{
			URI uri = URI.Parse(aURL, "http", 0); // default to 0 so we can set SSL port
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
