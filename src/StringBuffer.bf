using System;

namespace Beef_Net
{
	struct StringBuffer
	{
	    public char8* Memory;
	    public char8* Pos;
		public int Length { get; private set mut; }

		public static StringBuffer InitStringBuffer(int aInitialSize)
		{
			StringBuffer result = .() {
				Memory = (char8*)Internal.Malloc(aInitialSize),
				Length = aInitialSize
			};
			result.Pos = result.Memory;
			return result;
		}

		public static void ClearStringBuffer(ref StringBuffer aBuffer) =>
			aBuffer.Pos = aBuffer.Memory;

		public static void AppendString(ref StringBuffer aBuffer, void* aSource, uint32 aLength)
		// lPos, lSize: PtrUInt;
		{
			if (aLength == 0)
				return;

			uint32 pos = (uint32)(aBuffer.Pos - aBuffer.Memory);
			uint32 size = (uint32)(Internal.CStrLen(aBuffer.Memory));

			// reserve 2 extra spaces
			if (pos + aLength + 2 >= size)
			{
				// ReallocMem(aBuffer.Memory, pos + aLength + size);
				char8* tmp = new char8[aBuffer.Length]*;
				Internal.MemCpy(tmp, aBuffer.Memory, aBuffer.Length);

				Internal.Free(aBuffer.Memory);

				aBuffer.Length = pos + aLength + size;
				aBuffer.Memory = (char8*)Internal.Malloc(aBuffer.Length);
				Internal.MemCpy(aBuffer.Memory, tmp, aBuffer.Length);
				aBuffer.Pos = aBuffer.Memory + pos;
				delete tmp;
			}

			Internal.MemMove(aBuffer.Pos, aSource, aLength);
			aBuffer.Pos += aLength;
		}
		
		public static void AppendString(ref StringBuffer aBuffer, char8* aSource)
		{
			if (aSource == null)
				return;

			AppendString(ref aBuffer, aSource, (uint32)Internal.CStrLen(aSource));
		}
		
		public static void AppendString(ref StringBuffer aBuffer, StringView aSource) =>
			AppendString(ref aBuffer, aSource.Ptr, (uint32)aSource.Length);
		
		public static void AppendChar(ref StringBuffer aBuffer, char8 aChar)
		{
			*aBuffer.Pos = aChar;
			aBuffer.Pos++;
		}
	}
}
