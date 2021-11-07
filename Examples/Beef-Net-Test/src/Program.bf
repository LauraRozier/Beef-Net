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
		private const StringView UrlOrig = "https://www.beeflang.org/docs/language-guide/operators/#assignment";
		private const StringView Base64Orig = "udwhrighttriangle    upside-down double whole right triangle notehead";
		private const StringView Base64ValidStr = "VGhlIEdyZWF0IFdhbGwgb2YgQ2hpbmEgaXMgdGhlIGJpZ2dlc3Qgb2JqZWN0IGV2ZXIgbWFkZSBieSBodW1hbnMuIEl0IHN0cmV0Y2hlcyBhY3Jvc3MgbW91bnRhaW5zLCBkZXNlcnRzLCBhbmQgZ3Jhc3NsYW5kcyBmb3Igb3ZlciA2LDAwMCBraWxvbWV0ZXJzLg==";

		private static bool _needsCleanup = false;

		static int Main()
		{
			StringList strList = scope .();
			String delimStr = scope .();
			String tmpStrEnc = scope .();
			String tmpStrDec = scope .();
			URI tmpUri = scope .();

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

			Console.WriteLine("Original URI        = {0}", UrlOrig);

			HttpUtil.HttpEncode(UrlOrig, tmpStrEnc);
			Console.WriteLine("HttpUtil.HTTPEncode = {0}", tmpStrEnc);

			HttpUtil.HttpDecode(tmpStrEnc, tmpStrDec);
			Console.WriteLine("HttpUtil.HTTPDecode = {0}\r\n", tmpStrDec);

			URI.Parse(UrlOrig, tmpUri);
			Console.WriteLine(
				"Protocol = {0}\r\nHasAuthority = {1}\r\nUsername = {2}\r\nPassword = {3}\r\nHost = {4}\r\nPort = {5}\r\nPath = {6}\r\nDocument = {7}\r\nParams = {8}\r\nBookmark = {9}",
				tmpUri.Protocol, tmpUri.HasAuthority, tmpUri.Username, tmpUri.Password, tmpUri.Host, tmpUri.Port,
				tmpUri.Path, tmpUri.Document, tmpUri.Params, tmpUri.Bookmark
			);

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");
			
			Console.WriteLine("StringList Test:");
			strList.SetText("This\ris just\nsome random\r\ntext, really");

			for (var item in strList)
				Console.WriteLine("  - {0}", item);

			strList.GetText(delimStr);
			Console.WriteLine("Delimited Output:\r\n{0}", delimStr);
			ClearAndDeleteItems!(strList);

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			Console.WriteLine("Original string       = {0}", Base64Orig);

			EncodeBase64(Base64Orig, tmpStrEnc);
			Console.WriteLine("Base64 encoded string = {0}", tmpStrEnc);

			DecodeBase64(tmpStrEnc, tmpStrDec);
			Console.WriteLine("Base64 decoded string = {0}", tmpStrDec);

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			Console.WriteLine("Original string              = {0}", Base64ValidStr);

			DecodeBase64(Base64ValidStr, tmpStrDec);
			Console.WriteLine("Base64 decoded string Strict = {0}", tmpStrDec);

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			TimeSpan ts = TimeZoneInfo.Local.GetUtcOffset(DateTime.UtcNow);
			TimeZoneInfo tzi = TrySilent!(TimeZoneInfo.FindSystemTimeZoneById("Newfoundland Standard Time"));
			TimeSpan ts2 = tzi.GetUtcOffset(DateTime.UtcNow);
			int32 utcOffset = (ts.Hours * 100) + ts.Minutes;
			int32 utcOffset2 = (ts2.Hours * 100) + ts2.Minutes;

			if (utcOffset > 0)
				Console.WriteLine("Format Test = +{0:D4}", utcOffset);
			else
				Console.WriteLine("Format Test = {0:D4}", utcOffset);

			if (utcOffset2 > 0)
				Console.WriteLine("Format Test NST = +{0:D4}", utcOffset2);
			else
				Console.WriteLine("Format Test NST = {0:D4}", utcOffset2);

			delete tzi;

			Console.WriteLine("\r\n\r\n-----------------------------------------------\r\n\r\n");

			Console.WriteLine("Press any key to continue...");
			ConsoleExt.ReadKey(true);

			Beef_Net_Cleanup();
			return 0;
		}

		protected static void EncodeBase64(StringView aStr, String aOutStr)
		{
			aOutStr.Clear();

			if (aStr.IsEmpty)
				return;

			MemoryStream dummy = scope .();
			Base64EncodingStream enc = new .(dummy);

			enc.TryWrite(.((uint8*)aStr.Ptr, aStr.Length));
			delete enc;
			
			dummy.Seek(0);
			dummy.TryRead(.((uint8*)aOutStr.PrepareBuffer(dummy.Length), dummy.Length));
		}

		protected static void DecodeBase64(StringView aStr, String aOutStr)
		{
			aOutStr.Clear();

			if (aStr.IsEmpty)
				return;

			MemoryStream dummy = scope .();
			Base64DecodingStream dec = scope .(dummy);

			dummy.TryWrite(.((uint8*)aStr.Ptr, aStr.Length));
			dummy.Seek(0);
			dec.TryRead(.((uint8*)aOutStr.PrepareBuffer(dec.Length), dec.Length));
		}

		protected static void DecodeBase64Strict(StringView aStr, String aOutStr)
		{
			aOutStr.Clear();

			if (aStr.IsEmpty)
				return;

			MemoryStream dummy = scope .();
			Base64DecodingStream dec = scope .(dummy, .Strict);

			dummy.TryWrite(.((uint8*)aStr.Ptr, aStr.Length));
			dummy.Seek(0);
			dec.TryRead(.((uint8*)aOutStr.PrepareBuffer(dec.Length), dec.Length));
		}
	}
}
