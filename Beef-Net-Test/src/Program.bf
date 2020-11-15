using System;
using Beef_Net;

namespace Beef_Net_Test
{
	class Program
	{
		static int Main()
		{
			String tmp = scope:: .(OpenSSL.AES_options());
			Console.Out.WriteLine(tmp);

			Console.Out.WriteLine("Press [Enter]  to exit...");
			Console.In.Read();
			return 0;
		}
	}
}
