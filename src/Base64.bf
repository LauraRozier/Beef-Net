using System;
using System.IO;

namespace Beef_Net
{
	/* The Base64DecodingStream supports two modes:
	 * - 'strict mode':
	 *    - follows RFC3548
	 *    - rejects any characters outside of base64 alphabet,
	 *    - only accepts up to two '=' characters at the end and
	 *    - requires the input to have a Size being a multiple of 4; otherwise raises an EBase64DecodingException
	 * - 'MIME mode':
	 *    - follows RFC2045
	 *    - ignores any characters outside of base64 alphabet
	 *    - takes any '=' as end of string
	 *    - handles apparently truncated input streams gracefully
	 */ 
	public enum Base64DecodingMode
	{
		Strict,
		MIME
	}

	public abstract class Base64OwnerStream : MemoryStream
	{
		protected readonly static char8[] AlphabetNoPad = new .[64](
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'+', '/'
		) ~ delete _;

		protected bool _owner = false;
		protected Stream _source = null;

		public bool SourceOwner
		{
			get { return _owner; }
			set { _owner = value; }
		}

		public Stream Source { get { return _source; } }

		public this(Stream aSource, bool aIndOwnsStream = false) : base()
		{
			_source = aSource;
			_owner = aIndOwnsStream;
		}

		public ~this()
		{
			if (_owner)
				delete _source;
		}
	}

	public class Base64EncodingStream : Base64OwnerStream
	{
		protected int64 _totalBytesProcessed = 0;
		protected int64 _bytesWritten = 0;
		protected uint8[] _buf = new .[3] ~ delete _;
		protected uint8 _bufSize = 0;                 // # of bytes used in _buf

		public this(Stream aSource, bool aIndOwnsStream = false) : base(aSource, aIndOwnsStream) { }

		public ~this()
		{
			Flush();
		}

		public override Result<void> Flush()
		{
			char8* writeBuf = scope .[4]*;

			// Fill output to multiple of 4 
			switch (_totalBytesProcessed % 3)
			{
			case 1:
				{
					writeBuf[0] = AlphabetNoPad[ _buf[0]      >> 2];
					writeBuf[1] = AlphabetNoPad[(_buf[0] & 3) << 4];
					writeBuf[2] = '=';
					writeBuf[3] = '=';

					if (_source.TryWrite(.((uint8*)writeBuf, 4)) case .Ok)
						_totalBytesProcessed += 2;
				}
			case 2:
				{
					writeBuf[0] = AlphabetNoPad[  _buf[0]       >> 2];
					writeBuf[1] = AlphabetNoPad[((_buf[0] &  3) << 4) | (_buf[1] >> 4)];
					writeBuf[2] = AlphabetNoPad[ (_buf[1] & 15) << 2];
					writeBuf[3] = '=';

					if (_source.TryWrite(.((uint8*)writeBuf, 4)) case .Ok)
						_totalBytesProcessed++;
				}
			default: break;
			}

			return .Ok;
		}

		public override Result<int> TryWrite(Span<uint8> data)
		{
			int count = data.Length;
			int result = count;
			int readNow = 0;
			uint8* ptr = data.Ptr;
			char8* writeBuf = scope .[4]*;

			_totalBytesProcessed += count;

			while (count > 0)
			{
				// Fetch data into the Buffer
				readNow = 3 - _bufSize;

				if (readNow > count)
					break; // Not enough data available

				Internal.MemMove(&_buf[_bufSize], ptr, readNow);
				ptr += readNow;
				count -= readNow;

				// Encode the 3 bytes in _buf
				writeBuf[0] = AlphabetNoPad[  _buf[0]       >> 2];
				writeBuf[1] = AlphabetNoPad[((_buf[0] &  3) << 4) | (_buf[1] >> 4)];
				writeBuf[2] = AlphabetNoPad[((_buf[1] & 15) << 2) | (_buf[2] >> 6)];
				writeBuf[3] = AlphabetNoPad[  _buf[2] & 63];

				if (_source.TryWrite(.((uint8*)writeBuf, 4)) case .Err)
					return .Err;

				_bytesWritten += 4;
				_bufSize = 0;
			}

			Internal.MemMove(&_buf[_bufSize], ptr, count);
			_bufSize += (uint8)count;
			return .Ok(result);
		}

		public override Result<void> Seek(int64 pos, SeekKind seekKind = .Absolute)
		{
			int64 res = _bytesWritten;

			if (_bufSize > 0)
				res += 4;

			// This stream only supports the Seek modes needed for determining its size
			if (!(((seekKind == .Relative || seekKind == .FromEnd) && pos == 0) || (seekKind == .Absolute && pos == res)))
				Runtime.FatalError("Invalid stream operation");

			return .Ok;
		}
	}

	public class Base64DecodingStream : Base64OwnerStream
	{
		private Base64DecodingMode _mode = .MIME;

		protected const uint8 NA = 85;  // Not in base64 alphabet at all; binary: 01010101
		protected const uint8 PC = 255; // Padding character                      11111111
		protected readonly static uint8[] DecodingTable = new .[256](
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, // 0-15
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, // 16-31
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 62, NA, NA, NA, 63, // 32-47
			52, 53, 54, 55, 56, 57, 58, 59, 60, 61, NA, NA, NA, PC, NA, NA, // 48-63
			NA, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, // 64-79
			15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, NA, NA, NA, NA, NA, // 80-95
			NA, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, // 96-111
			41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, NA, NA, NA, NA, NA, // 112-127
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
			NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
		) ~ delete _;
		protected readonly static char8[] Alphabet = new .[65](
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'+', '/', '='
		) ~ delete _; // All 65 chars that are in the base64 encoding alphabet

		protected int64 _curPos = 0;                  // 0-based (decoded) position of this stream (nr. of decoded & Read bytes since last reset)
		protected int64 _decodedSize = 0;             // Length of decoded stream ((expected) decoded bytes since last Reset until Mode-dependent end of stream)
		protected int64 _readBase64ByteCount = 0;     // Number of valid base64 bytes read from input stream since last Reset
		protected uint8[] _buf = new .[3] ~ delete _; // Last 3 decoded bytes
		protected uint8 _bufPos = 0;                  // Offset in Buf of byte which is to be read next; if >2, next block must be read from Source & decoded
		protected bool _eof = false;                  // If true, all decoded bytes have been read

		public override int64 Position { get { return _curPos; } }
		public override int64 Length
		{
			get
			{
				// Note: This method only works on Seekable Sources (for Base64DecodingMode.Strict we also get the Size property)
				if (_decodedSize != -1)
					return _decodedSize;

				int64 result = 0;
				int64 iPos = _source.Position; // Save the current position of the input stream

				switch (_mode)
				{
				case .MIME:
					{
						char8* scanBuf = scope .[1024]*;
						int64 count = 0;
						char8 char = 0;
						result = _readBase64ByteCount; // Keep the number of valid base64 bytes since last Reset in Result
						
						// Read until end of input stream or first occurrence of an '=' char
						repeat
						{
							count = TrySilent!(_source.TryRead(.((uint8*)scanBuf, 1024)));

							for (int i = 0; i < count; i++)
							{
								char = scanBuf[i];

								if (HttpUtil.Search(AlphabetNoPad, char) > -1) // Base64 encoding characters except '=' (padding char)
									result++;
								else if (char == '=') // End marker '=' / padding
									break;
							}
						}
						while (count > 0);

						// We are now either at the end of the stream, or encountered our first '=', stored in char
						if (char == '=') // '=' found
						{
							if (result % 4 <= 1) // Badly placed '=', disregard last block
								result = (result / 4) * 3;
							else // 4 byte block ended with '=' or '=='
								result = ((result / 4) * 3) + ((result % 4) - 1);
						}
						else // End of stream
						{
							result = (result / 4) * 3; // Number of valid 4 byte blocks times 3
						}
					}
				case .Strict:
					{
						// Seek to end of input stream, read last two bytes and determine size from Source size and the number of leading '=' bytes
						// NB we don't raise an exception here if the input does not contains an integer multiple of 4 bytes
						char8* endBytes = scope .[2]*;
						int64 iSize = _source.Length;
						iPos = _source.Position;
						result = ((_readBase64ByteCount + (iSize - iPos) + 3) / 4) * 3;
						_source.Seek(iSize - 2);
						_source.TryRead(.((uint8*)endBytes, 2));

						if (endBytes[1] == '=') // Last byte
						{
							result--;

							if (endBytes[0] == '=') // Second to last byte
								result--;
						}
					}
				}

				_source.Position = iPos; // Restore position in input stream
				_decodedSize = result;   // Store calculated _decodedSize 
				return result;
			}
		}
		public Base64DecodingMode Mode
		{
			get { return _mode; }
			set
			{
				if (_mode == value)
					return;

				_mode = value;
				_decodedSize = -1; // Forget any calculations on this
			}
		}
		public bool EOF { get { return _eof; } }

		public this(Stream aSource, Base64DecodingMode aMode = .MIME, bool aIndOwnsStream = false) : base(aSource, aIndOwnsStream)
		{
			_mode = aMode;
			Reset();
		}

		public void Reset()
		{
			_readBase64ByteCount = 0; // Number of bytes Read form Source since last call to Reset
			_curPos = 0;              // Position in decoded byte sequence since last Reset
			_decodedSize = -1;        // Indicates unknown; will be set after first call to GetSize or when reaching end of stream
			_bufPos = 3;              // Signals we need to read & decode a new block of 4 bytes
			_eof = false;
		}

		public override Result<int> TryRead(Span<uint8> data)
		{
			int result = 0;
			int count = data.Length;

			mixin DetectedEnd(int64 aSize)
			{
				_decodedSize = aSize;

				// Correct Count if at end of base64 input
				if (_curPos + count > _decodedSize)
					count = (int)(_decodedSize - _curPos);
			}

			if (data.Length <= 0) // Nothing to read, quit
				return .Ok(0);

			if (_decodedSize != -1) // Try using calculated size info if possible
			{
				if (_curPos + count > _decodedSize)
					count = (int)(_decodedSize - _curPos);

				if (count <= 0)
					return .Ok(0);
			}

			uint8* ptr = data.Ptr;
			uint8* readBuf = scope .[4]*;
			uint8 byte;
			int toRead, readOK, orgToRead, haveRead;

			while (true)
			{
				// Get new 4-byte block if at end of _buf
				if (_bufPos > 2)
				{
					_bufPos = 0;
					// Read the next 4 valid bytes
					toRead = 4; // number of base64 bytes left to read into ReadBuf
					readOK = 0; // number of base64 bytes already read into ReadBuf

					while (toRead > 0)
					{
						orgToRead = toRead;
						haveRead = TrySilent!(_source.TryRead(.(&readBuf[readOK], toRead)));

						if (haveRead > 0) // If any new bytes; in ReadBuf[ReadOK .. ReadOK + HaveRead-1]
						{
							for (int i = readOK; i < readOK + haveRead; i++)
							{
								byte = DecodingTable[readBuf[i]];

								if (byte != NA) // Valid base64 alphabet character ('=' inclusive)
								{
									readBuf[readOK++] = byte;
									toRead--;
								}
								else if (_mode == .Strict) // Invalid character
								{
									Runtime.FatalError("Non-valid Base64 Encoding character in input");
								}
							}
						}

						if (haveRead != orgToRead) // Less than 4 base64 bytes could be read; end of input stream
						{
							for (int i = readOK; i < 4; i++)
								readBuf[i] = 0; // Pad buffer with zeros so decoding of 4-bytes will be correct

							if (_mode == .Strict && readOK > 0)
								Runtime.FatalError("Input stream was truncated at non-4 byte boundary");

							break;
						}
					}

					_readBase64ByteCount += 2;

					switch (_mode)
					{
					case .Strict:
						{
							if (readOK == 0)
							{
								// End of input stream was reached at 4-byte boundary
								DetectedEnd!(_curPos);
							}
							else if (readBuf[0] == PC || readBuf[1] == PC)
							{
								// =BBB or B=BB
								Runtime.FatalError("Unexpected padding character '=' before end of input stream");
							}
							else if (readBuf[2] == PC)
							{
								if (readBuf[3] != PC || _source.Position < _source.Length) // BB=B or BB==, but not at end of input stream
									Runtime.FatalError("Unexpected padding character '=' before end of input stream");

								DetectedEnd!(_curPos + 1); // Only one byte left to read;  BB==, at end of input stream
							}
							else if (readBuf[3] == PC)
							{
								if (_source.Position < _source.Length) // BBB=, but not at end of input stream
									Runtime.FatalError("Unexpected padding character '=' before end of input stream");

								DetectedEnd!(_curPos + 2); // Only two bytes left to read; BBB=, at end of input stream
							}
						}
					case .MIME:
						{
							if (readOK == 0)
								DetectedEnd!(_curPos);     // End of input stream was reached at 4-byte boundary
							else if (readBuf[0] == PC || readBuf[1] == PC)
								DetectedEnd!(_curPos);     // =BBB or B=BB: end here
							else if (readBuf[2] == PC)
								DetectedEnd!(_curPos + 1); // Only one byte left to read;  BB=B or BB==
							else if (readBuf[3] == PC)
								DetectedEnd!(_curPos + 2); // Only two bytes left to read; BBB=
						}
					}

					// Decode the 4 bytes in the buffer to 3 undecoded bytes
					_buf[0] =  (readBuf[0]       << 2) | (readBuf[1] >> 4);
					_buf[1] = ((readBuf[1] & 15) << 4) | (readBuf[2] >> 2);
					_buf[2] = ((readBuf[2] &  3) << 6) |  readBuf[3];
				}

				if (count <= 0)
					break;

				*ptr = _buf[_bufPos];
				ptr++;
				_bufPos++;
				_curPos++;
				count--;
				result++;
			}

			// Check for EOF  
			if (_decodedSize != -1 && _curPos >= _decodedSize)
				_eof = true;

			return .Ok(result);
		}

		public override Result<void> Seek(int64 pos, SeekKind seekKind = .Absolute) =>
			Runtime.FatalError("Invalid stream operation");
	}
}
