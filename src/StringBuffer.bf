using System;

namespace Beef_Net
{
	public struct StringBuffer
	{
	    public char8* Memory;
	    public char8* Pos;
		public int Length { get; private set mut; }

		public static StringBuffer Init(int aInitialSize)
		{
			StringBuffer result = .() {
				Memory = (char8*)Internal.Malloc(aInitialSize),
				Length = aInitialSize
			};
			result.Pos = result.Memory;
			return result;
		}

		public void Clear() mut =>
			Pos = Memory;

		public static void ClearStringBuffer(ref StringBuffer aBuffer) =>
			aBuffer.Pos = aBuffer.Memory;

		public void AppendString(void* aSource, uint32 aLength) mut
		// lPos, lSize: PtrUInt;
		{
			if (aLength == 0)
				return;

			uint32 pos = (uint32)(Pos - Memory);
			uint32 size = (uint32)(Internal.CStrLen(Memory));

			// reserve 2 extra spaces
			if (pos + aLength + 2 >= size)
			{
				// ReallocMem(aBuffer.Memory, pos + aLength + size);
				char8* tmp = new char8[Length]*;
				Internal.MemCpy(tmp, Memory, Length);

				Internal.Free(Memory);

				Length = pos + aLength + size;
				Memory = (char8*)Internal.Malloc(Length);
				Internal.MemCpy(Memory, tmp, Length);
				Pos = Memory + pos;
				delete tmp;
			}

			Internal.MemMove(Pos, aSource, aLength);
			Pos += aLength;
		}
		
		public void AppendString(char8* aSource) mut
		{
			if (aSource == null)
				return;

			AppendString(aSource, (uint32)Internal.CStrLen(aSource));
		}
		
		public void AppendString(StringView aSource) mut =>
			AppendString(aSource.Ptr, (uint32)aSource.Length);
		
		public void AppendChar(char8 aChar) mut
		{
			*Pos = aChar;
			Pos++;
		}
	}
}
