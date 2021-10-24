using System;
using System.Collections;
using System.Globalization;

namespace Beef_Net
{
	class StringList : List<String>
	{
		private readonly static char8[] NewlineChars = new .[2]('\n', '\r') ~ delete _;

		private bool _skipLastLineBreak = false;
		private bool _strictDelimiter = false;
		private bool _alwaysQuote = false;
		private char8 _delimiter = ',';
		private char8 _quoteChar = '"';
		private String _defaultLineBreak =  new .(Environment.NewLine) ~ delete _;
		private String _lineBreak = new .(Environment.NewLine) ~ delete _;

		public bool SkipLastLineBreak
		{
			get { return _skipLastLineBreak; }
			set { _skipLastLineBreak = value; }
		}
		public bool StrictDelimiter
		{
			get { return _strictDelimiter; }
			set { _strictDelimiter = value; }
		}
		public bool AlwaysQuote
		{
			get { return _alwaysQuote; }
			set { _alwaysQuote = value; }
		}
		public char8 Delimiter
		{
			get { return _delimiter; }
			set { _delimiter = value; }
		}
		public char8 QuoteChar
		{
			get { return _quoteChar; }
			set { _quoteChar = value; }
		}

		public void GetText(String aOutStr)
		{
			aOutStr.Clear();
			String newline = scope .();

			if (!_lineBreak.Equals(Environment.NewLine, .OrdinalIgnoreCase))
				newline.Append(_lineBreak);
			else
				newline.Append(_defaultLineBreak);

			for (var item in this)
				aOutStr.Append(item, newline);

			if (_skipLastLineBreak)
				aOutStr.RemoveFromEnd(newline.Length);
		}

		public void SetText(StringView aStr)
		{
			String tmp = scope .();
			int pos = 0;
			ClearAndDeleteItems!(this);

			if (_lineBreak.Equals(Environment.NewLine, .OrdinalIgnoreCase))
			{
				while (GetNextLine(aStr, tmp, ref pos))
					Add(new .(tmp));
			}
			else
			{
				while (GetNextLineBreak(aStr, tmp, ref pos))
					Add(new .(tmp));
			}
		}

		public void GetCommaText(String aOutStr)
		{
			char8 c1 = _delimiter;
			char8 c2 = _quoteChar;
			bool fsd = _strictDelimiter;

			_delimiter = ',';
			_quoteChar = '"';
 			_strictDelimiter = false;

			GetDelimitedText(aOutStr);

			_delimiter = c1;
			_quoteChar = c2;
 			_strictDelimiter = fsd;
		}

		public void SetCommaText(StringView aStr)
		{
			char8 c1 = _delimiter;
			char8 c2 = _quoteChar;

			_delimiter = ',';
			_quoteChar = '"';

			SetDelimitedText(aStr);
			
			_delimiter = c1;
			_quoteChar = c2;
		}

		private bool GetNextLine(StringView aStr, String aOutStr, ref int aPos)
		{
			int len = aStr.Length;
			aOutStr.Clear();

			if (len - aPos <= 0)
				return false;

			if (len - aPos == 1 && HttpUtil.Search(NewlineChars, aStr[aPos]) == -1)
			{
				aOutStr.Append(aStr[aPos++]);
				return true;
			}

			while (len - aPos > 0 && HttpUtil.Search(NewlineChars, aStr[aPos]) == -1)
				aOutStr.Append(aStr[aPos++]);

			if (aPos < len && aStr[aPos] == '\r') // Point to character after #13
				aPos++;

			if (aPos < len && aStr[aPos] == '\n') // Point to character after #10
				aPos++;

			return true;
		}

		private bool GetNextLineBreak(StringView aStr, String aOutStr, ref int aPos)
		{
			aOutStr.Clear();

			if (aStr.Length - aPos <= 0)
				return false;
			
			StringView tmp = aStr.Substring(aPos);
			int idx = tmp.IndexOf(_lineBreak, 0);

			if (idx > -1)
			{
				aOutStr.Append(tmp.Substring(0, aPos));
				aPos += idx + _lineBreak.Length;
			}
			else
			{
				aOutStr.Append(tmp);
				aPos += tmp.Length;
			}

			return true;
		}

		public void GetDelimitedText(String aOutStr)
		{
			aOutStr.Clear();
			char8[] breakChars;
			String str;
			bool doQuote;
			int j;

			if (_strictDelimiter)
				// [#0,QuoteChar,Delimiter]
				breakChars = new .[3](0x0, _quoteChar, _delimiter);
			else
				// [#0..' ',QuoteChar,Delimiter]
				breakChars = new .[35](
					'\x00', '\x01', '\x02', '\x03', '\x04', '\x05', '\x06', '\x07', '\x08', '\x09', '\x0A', '\x0B', '\x0C', '\x0D', '\x0E', '\x0F',
					'\x10', '\x11', '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19', '\x1A', '\x1B', '\x1C', '\x1D', '\x1E', '\x1F',
					'\x20', _quoteChar, _delimiter
				);

			// Check for break characters and quote if required.
			for (int i = 0; i < Count; i++)
			{
				str = this[i];
				doQuote = _alwaysQuote;

				if (!doQuote)
				{
					j = 0;

					// Quote strings that include BreakChars
					while (j < str.Length && HttpUtil.Search(breakChars, str[j]) == -1)
						j++;

					doQuote = j < str.Length - 1;
				}

				if (doQuote)
					QuoteString(str, _quoteChar, aOutStr);
				else
					aOutStr.Append(str);

				if (i < Count - 1)
					aOutStr.Append(_delimiter);
			}

			delete breakChars;

			// Quote empty string
			if (aOutStr.Length == 0 && Count == 1)
				aOutStr.Append(_quoteChar, 2);
		}

		private void QuoteString(StringView aStr, char8 aQuoteChar, String aOutStr)
		{
			int_strsize j = 0;
			String tmp = scope .(aStr);

			for (int i = 0; i < aStr.Length; i++)
			{
				if (aStr[i] == aQuoteChar)
					tmp.Insert(j++, aQuoteChar);

				j++;
			}

			aOutStr.Append(aQuoteChar);
			aOutStr.Append(tmp);
			aOutStr.Append(aQuoteChar);
		}

		public void SetDelimitedText(StringView aStr)
		{
			int i = 0;
			int j = 0;
			bool notFirst = false;

			/*
			Strings must be separated by Delimiter characters or spaces.  They may be enclosed in QuoteChars.
			QuoteChars in the string must be repeated to distinguish them from the QuoteChars enclosing the string.
			*/
			ClearAndDeleteItems!(this);

			if (_strictDelimiter)
			{
				while (i < aStr.Length)
				{
					// Skip delimiter
					if (notFirst && i < aStr.Length && aStr[i] == _delimiter)
						i++;

					// Read next string
					if (i < aStr.Length)
					{
						if (aStr[i] == _quoteChar)
						{
       						// Next string is quoted
							j = i + 1;

							while (j < aStr.Length && (aStr[j] != _quoteChar || (j + 1 < aStr.Length && aStr[j + 1] == _quoteChar)))
							{
								if (j < aStr.Length && aStr[j] == _quoteChar)
									j += 2;
								else
									j++;
							}

							// j is position of closing quote
							String tmp = new .(aStr.Substring(i + 1, j - i - 1));
							tmp.Replace(scope .(_quoteChar, 2), scope .(_quoteChar, 1));
							Add(tmp);
							i = j + 1;
						}
						else
						{
       						// Next string is not quoted; read until delimiter
							j = i;

							while (j < aStr.Length && aStr[j] != _delimiter)
								j++;

							Add(new .(aStr.Substring(i, j - i)));
							i = j;
						}
					}
					else if (notFirst)
					{
						Add(new .());
					}

					notFirst = true;
				}
			}
			else
			{
				while (i < aStr.Length)
				{
     				// skip delimiter
					if (notFirst && i < aStr.Length && aStr[i] == _delimiter)
						i++;

					// skip spaces
					while (i < aStr.Length && ((uint8)aStr[i]) <= ((uint8)' '))
						i++;

					// Read next string
					if (i < aStr.Length)
					{
						if (aStr[i] == _quoteChar)
						{
       						// Next string is quoted
							j = i + 1;

							while (j < aStr.Length && (aStr[j] != _quoteChar || (j + 1 < aStr.Length && aStr[j + 1] == _quoteChar)))
							{
								if (j < aStr.Length && aStr[j] == _quoteChar)
									j += 2;
								else
									j++;
							}

							// j is position of closing quote
							String tmp = new .(aStr.Substring(i + 1, j - i - 1));
							tmp.Replace(scope .(_quoteChar, 2), scope .(_quoteChar, 1));
							Add(tmp);
							i = j + 1;
						}
						else
						{
							// Next string is not quoted; read until control character/space/delimiter
							j = i;

							while (j < aStr.Length && ((uint8)aStr[j]) > ((uint8)' ') && aStr[j] != _delimiter)
								j++;

							Add(new .(aStr.Substring(i, j - i)));
							i = j;
						}
					}
					else if (notFirst)
					{
						Add(new .());
					}

					// skip spaces
					while (i < aStr.Length && ((uint8)aStr[i]) <= ((uint8)' '))
						i++;

					notFirst = true;
				}
			}
		}
	}
}
