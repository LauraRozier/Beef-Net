using System;
using System.Collections;
using System.Globalization;

namespace Beef_Net
{
	class StringList : List<String>
	{
		private readonly static char8[] NewlineChars = new .[2]('\n', '\r') ~ delete _;

		private bool _skipLastLineBreak = false;
		private String _defaultLineBreak =  new .(Environment.NewLine) ~ delete _;
		private String _lineBreak = new .(Environment.NewLine) ~ delete _;

		public bool SkipLastLineBreak
		{
			get { return _skipLastLineBreak; }
			set { _skipLastLineBreak = value; }
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
	}
}
