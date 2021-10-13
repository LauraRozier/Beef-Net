using System;
using System.Collections;
using System.IO;

namespace Beef_Net
{
	public class MimeList : Dictionary<String, String>
	{
		private readonly static char8[] SkipChars = new .[2]((char8)9, ' ') ~ delete _;

		public this(StringView aFileName) : this()
		{
			if (Count > 0 || !File.Exists(aFileName))
				return;

			StreamReader sr = scope .();

			if (sr.Open(aFileName) case .Err)
				return;

			String line = scope .();
			String name = scope .();
			int charPos = 0;
			int nextPos = 0;

			repeat
			{
				line.Clear();

				if (sr.ReadLine(line) case .Err)
					return;

				if (line.Length == 0 || line[0] == '#')
					continue;

				charPos = line.IndexOf((char8)9); // TAB char

				if (charPos == -1)
					continue;

				name.Set(line.Substring(0, charPos));

				while (charPos < line.Length && HttpUtil.Search(SkipChars, line[charPos]) > -1)
					charPos++;

				if (charPos >= line.Length)
					continue;

				repeat
				{
					nextPos = line.IndexOf(' ', charPos);

					if (nextPos == -1)
						nextPos = line.Length;

					this.Add(new .(line.Substring(charPos, nextPos - charPos)), new .(name));
					charPos = nextPos + 1;
				}
				while (charPos < line.Length);
			}
			while (!sr.EndOfStream);

			sr.Dispose();
		}
	}
}
