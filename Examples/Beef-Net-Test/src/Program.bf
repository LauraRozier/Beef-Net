using System;
using System.IO;
using System.Threading;
using Beef_Net;
using Beef_Net_Common;
using Beef_OpenSSL;

namespace Beef_Net_Test
{
	class Program
	{
		private static bool _needsCleanup = false;

		static int Main()
		{
			Beef_Net_Init();
			ConsoleExt.PrepHandles();

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			String tmp = scope:: .(AES.options());
			tmp.Append("\n\nOpenSSL.VERSION     = ");
			tmp.Append(OpenSSL.version(OpenSSL.VERSION));
			tmp.Append("\nOpenSSL.CFLAGS      = ");
			tmp.Append(OpenSSL.version(OpenSSL.CFLAGS));
			tmp.Append("\nOpenSSL.BUILT_ON    = ");
			tmp.Append(OpenSSL.version(OpenSSL.BUILT_ON));
			tmp.Append("\nOpenSSL.PLATFORM    = ");
			tmp.Append(OpenSSL.version(OpenSSL.PLATFORM));
			tmp.Append("\nOpenSSL.DIR         = ");
			tmp.Append(OpenSSL.version(OpenSSL.DIR));
			tmp.Append("\nOpenSSL.ENGINES_DIR = ");
			tmp.Append(OpenSSL.version(OpenSSL.ENGINES_DIR));
			Console.WriteLine(tmp);

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			String tmpStrOrig = "https://www.beeflang.org/docs/language-guide/operators/#assignment";
			Console.WriteLine("Original URI = {0}", tmpStrOrig);

			String tmpStrEnc = scope .();
			HttpUtil.HTTPEncode(tmpStrOrig, tmpStrEnc);
			Console.WriteLine("HttpUtil.HTTPEncode = {0}", tmpStrEnc);

			String tmpStrDec = scope .();
			HttpUtil.HTTPDecode(tmpStrEnc, tmpStrDec);
			Console.WriteLine("HttpUtil.HTTPDecode = {0}\r\n", tmpStrDec);

			URI tmpUri = scope .();
			URI.Parse(tmpStrOrig, tmpUri);
			Console.WriteLine(
				"Protocol = {0}\r\nHasAuthority = {1}\r\nUsername = {2}\r\nPassword = {3}\r\nHost = {4}\r\nPort = {5}\r\nPath = {6}\r\nDocument = {7}\r\nParams = {8}\r\nBookmark = {9}",
				tmpUri.Protocol, tmpUri.HasAuthority, tmpUri.Username, tmpUri.Password, tmpUri.Host, tmpUri.Port,
				tmpUri.Path, tmpUri.Document, tmpUri.Params, tmpUri.Bookmark
			);

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");
			
			Console.WriteLine("StringList Test:");
			StringList strList = scope .();
			String delimStr = scope .();
			strList.SetText("This\ris just\nsome random\r\ntext, really");

			for (var item in strList)
				Console.WriteLine("  - {0}", item);

			strList.GetText(delimStr);
			Console.WriteLine("Delimited Output:\r\n{0}", delimStr);
			ClearAndDeleteItems!(strList);

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			Console.WriteLine("Press any key to continue...");
			ConsoleExt.ReadKey(true);

			Beef_Net_Cleanup();
			return 0;
		}
	}
}
