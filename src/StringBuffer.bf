using System;

namespace Beef_Net
{
	public struct StringBuffer
	{
		private int _length = 0;

	    public char8* Memory;
	    public char8* Pos;
		public int Length
		{
			get { return _length; }
		}

		public static StringBuffer Init(int aInitialSize)
		{
			StringBuffer result = .() {
				Memory = (char8*)Internal.Malloc(aInitialSize),
				_length = aInitialSize
			};
			result.Pos = result.Memory;
			return result;
		}

		public void Clear() mut =>
			Pos = Memory;

		public void Free() mut
		{
			Pos = null;
			Internal.Free(Memory);
			Memory = null;
		}

		public static void ClearStringBuffer(ref StringBuffer aBuffer) =>
			aBuffer.Pos = aBuffer.Memory;

		public void AppendString(void* aSource, int32 aLength, bool aIndStripNull = false) mut
		{
			var aLength;

			if (aLength == 0)
				return;

			if (aIndStripNull)
			{
				for (int i = aLength - 1; i > 0; i--)
				{
					if (((char8*)aSource)[i] == 0x0)
						aLength--;
					else
						break;
				}
			}

			int32 curSize = (int32)(Pos - Memory);

			// Reserve 2 extra spaces
			if (curSize + aLength + 2 >= _length)
			{
				// ReallocMem(aBuffer.Memory, pos + aLength + size);
				char8* tmp = new char8[_length]*;
				Internal.MemCpy(tmp, Memory, _length);

				Internal.Free(Memory);

				_length = curSize + aLength + 2;
				Memory = (char8*)Internal.Malloc(_length);
				Internal.MemCpy(Memory, tmp, _length);
				Pos = Memory + curSize;
				delete tmp;
			}

			Internal.MemMove(Pos, aSource, aLength);
			Pos += aLength;
		}
		
		public void AppendString(char8* aSource, bool aIndStripNull = false) mut
		{
			if (aSource == null)
				return;

			AppendString(aSource, Internal.CStrLen(aSource), aIndStripNull);
		}
		
		public void AppendString(String aSource, bool aIndStripNull = false) mut =>
			AppendString(aSource.Ptr, (int32)aSource.Length, aIndStripNull);
		
		public void AppendString(StringView aSource, bool aIndStripNull = false) mut =>
			AppendString(aSource.Ptr, (int32)aSource.Length, aIndStripNull);
		
		public void AppendChar(char8 aChar) mut
		{
			*Pos = aChar;
			Pos++;
		}
	}
}
