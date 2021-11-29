using System;
using System.IO;

namespace Beef_Net
{
	public enum MimeEncoding
	{
		case _8Bit;
		case Base64;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case ._8Bit:  return "8bit";
				case .Base64: return "base64";
				}
			}
		}
	}

	public enum MimeDisposition
	{
		case Inline;
		case Attachment;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .Inline:     return "inline";
				case .Attachment: return "attachment";
				}
			}
		}
	}

	public enum MimeType
	{
		case Mixed;
		case Alternative;

		public StringView StrVal
		{
			[NoDiscard]
			get
			{
				switch (this)
				{
				case .Mixed:       return "mixed";
				case .Alternative: return "alternative";
				}
			}
		}
	}

	public abstract class MimeSection
	{
		protected const StringView CRLF = "\r\n";

		protected MimeEncoding _encoding = ._8Bit;
		protected MimeDisposition _disposition = .Inline;
		protected bool _activated = false;
		protected String _contentType = new .() ~ delete _;
		protected String _description = new .() ~ delete _;
		protected String _buffer = new .() ~ delete _;
		protected Stream _encodingStream = null ~ if (_ != null) delete _;
		protected Stream _outputStream = null;
		protected MemoryStream _localStream = new .() ~ delete _;

    	public MimeEncoding Encoding
		{
			get { return _encoding; }
			set { SetEncoding(value); }
		}
    	public MimeDisposition Disposition
		{
			get { return _disposition; }
			set { SetDisposition(value); }
		}
    	public StringView ContentType
		{
			[NoDiscard]
			get { return _contentType; }
			set { _contentType.Set(value); }
		}
    	public StringView Description
		{
			[NoDiscard]
			get { return _description; }
			set { SetDescription(value); }
		}
    	public int Size { get { return GetSize(); } }

		public this(Stream aOutputStream)
		{
			_outputStream = aOutputStream;
		}

		protected int RecalculateSize(int aOriginalSize)
		{
			if (aOriginalSize == 0)
				return 0;

			switch (_encoding)
			{
			case ._8Bit:  return aOriginalSize;
			case .Base64:
				{
					if (aOriginalSize % 3 == 0)
						return (aOriginalSize / 3) * 4;       // This is simple, 4 bytes per 3 bytes
					else
						return ((aOriginalSize + 3) / 3) * 4; // Add "padding" trupplet
				}
			}
		}

		protected void SetEncoding(MimeEncoding aValue)
		{
			if (!_activated)
			{
				_encoding = aValue;

				if (_encodingStream != null)
					delete _encodingStream;

				CreateEncodingStream();
			}
		}

		protected void SetDisposition(MimeDisposition aValue)
		{
			if (!_activated)
				_disposition = aValue;
		}

		protected void SetDescription(StringView aValue)
		{
			if (!_activated)
				_description.Set(aValue);
		}

		protected virtual void CreateEncodingStream()
		{
			switch (_encoding)
			{
			case ._8Bit:  _encodingStream = null;
			case .Base64: _encodingStream = new Base64EncodingStream(_localStream);
			}
		}

		protected abstract int GetSize();

		protected abstract void FillBuffer(int aSize);

		public virtual void GetHeader(String aOutStr)
		{
			aOutStr.Clear();
			aOutStr.AppendF("Content-Type: {0}\r\nContent-Transfer-Encoding: {1}\r\nContent-Disposition: {2}\r\n", _contentType, _encoding.StrVal, _disposition.StrVal);

			if (_description.Length > 0)
				aOutStr.AppendF("Content-Description: {0}\r\n", _description);

			aOutStr.Append(CRLF);
		}

		public Result<int> TryRead(int aSize)
		{
			if (aSize <= 0)
				return .Ok(0);

			if (!_activated)
			{
				_activated = true;
				GetHeader(_buffer);
			}

			if (_buffer.Length < aSize)
				FillBuffer(aSize);

			String tmp = scope .();
			int result = 0;
			ReadBuffer(aSize, tmp);

			if (tmp.Length >= aSize)
			{
				result = TrySilent!(_outputStream.TryWrite(.((uint8*)tmp.Ptr, aSize)));
				_buffer.Remove(0, result);
			}
			else if (tmp.Length > 0)
			{
				result = TrySilent!(_outputStream.TryWrite(.((uint8*)tmp.Ptr, tmp.Length)));
				_buffer.Remove(0, result);
			}

			return .Ok(result);
		}

		public void ReadBuffer(int aSize, String aOutStr)
		{
			aOutStr.Clear();

			if (aSize >= _buffer.Length)
				FillBuffer(aSize);

			aOutStr.Append(_buffer.Substring(0, aSize));
		}

		public virtual void Reset()
		{
			_activated = false;
			_buffer.Clear();
			_localStream.Position = 0;
			SetEncoding(_encoding);
		}
	}

	public class MimeTextSection : MimeSection
	{
		protected String _originalData = new .() ~ delete _;
		protected String _data = new .() ~ delete _;

		public StringView Text
		{
			[NoDiscard]
			get { return _data; }
			set { SetData(value); }
		}

		public this(Stream aOutputStream, StringView aText) : base(aOutputStream)
		{
			_contentType.Set("text/plain; charset=\"UTF-8\"");
			_originalData.Set(aText);
			_data.Set(aText);
		}

		protected override int GetSize()
		{
			int result = _buffer.Length + RecalculateSize(_data.Length);

			if (!_activated) // Include header size only when not yet activated
			{
				String tmp = scope .();
				GetHeader(tmp);
				result += tmp.Length;
			}

			if ((!_activated) || _buffer.Length > 0 || _data.Length > 0)
				if (_originalData.Length > 0)
					result += CRLF.Length; // CRLF after each msg body

			return result;
		}

    	protected void SetData(StringView aValue)
		{
			if (!_activated)
			{
				_originalData.Set(aValue);
				_data.Set(aValue);
			}
		}

		protected override void FillBuffer(int aSize)
		{
			String tmp = scope .(_data.Substring(0, aSize));

			if (tmp.Length == 0)
				return;

			int len = aSize;

			if (_encodingStream != null)
			{
				len = TrySilent!(_encodingStream.TryWrite(.((uint8*)tmp.Ptr, tmp.Length)));
				_data.Remove(0, len);

				if (_data.Length == 0)
				{
					delete _encodingStream; // To fill in the last bit
					CreateEncodingStream();
					_localStream.TryWrite(.((uint8*)CRLF.Ptr, CRLF.Length));
				}

				tmp.PrepareBuffer((int)(_localStream.Length - tmp.Length));
				tmp.Length = TrySilent!(_localStream.TryRead(.((uint8*)tmp.Ptr, tmp.Length)));
			}
			else
			{
				_data.Remove(0, len);

				if (_data.Length == 0)
					tmp.Append(CRLF);
			}

			_buffer.Append(tmp);
		}
		
		public void GetCharset(String aOutStr)
		{
			aOutStr.Clear();

			int idx = _contentType.IndexOf('=');

			if (idx > 0)
			{
				aOutStr.Append(_contentType.Substring(idx + 1));
				aOutStr.Replace("\"", "");
			}
		}

		public void SetCharset(StringView aValue)
		{
			if (!_activated)
			{
				_contentType.Clear();

				if (aValue.Length > 0)
					_contentType.AppendF("text/plain; charset=\"{0}\"", aValue);
				else
					_contentType.Append("text/plain");
			}
		}

		public override void Reset()
		{
			base.Reset();
			_data.Set(_originalData);
		}
	}

	public class MimeStreamSection : MimeSection
	{
	    protected Stream _stream = null ~ if (_ownsStreams && _ != null) delete _;
	    protected bool _ownsStreams = false;
	    protected int64 _originalPosition = 0;

		public Stream Stream
		{
			get { return _stream; }
			set { SetStream(value); }
		}
		public bool OwnsStreams
		{
			get { return _ownsStreams; }
			set { _ownsStreams = value; }
		}

		public this(Stream aOutputStream, Stream aStream) : base(aOutputStream)
		{
			_disposition = .Attachment;
			_stream = aStream;
			_originalPosition = _stream.Position;
			_contentType.Set("application/octet-stream");
		}

		protected override int GetSize()
		{
			int result = _buffer.Length + RecalculateSize((int)(_stream.Length - _stream.Position));

			if (!_activated) // Include header size only when not yet activated
			{
				String tmp = scope .();
				GetHeader(tmp);
				result += tmp.Length;
			}

			if ((!_activated) || _buffer.Length > 0 || _stream.Length - _stream.Position > 0)
				if (_stream.Length - _originalPosition > 0)
					result += CRLF.Length; // CRLF after each msg body

			return result;
		}

		protected void SetStream(Stream aValue)
		{
			if (_stream == null && _ownsStreams)
				DeleteAndNullify!(_stream);

			_stream = aValue;
			_originalPosition = _stream.Position;
		}

		protected override void FillBuffer(int aSize)
		{
			String tmp = scope .();
			tmp.PrepareBuffer(aSize);
			tmp.Length = TrySilent!(_stream.TryRead(.((uint8*)tmp.Ptr, aSize)));

			if (tmp.Length <= 0)
				return;

			if (_encodingStream != null)
			{
				int len = TrySilent!(_encodingStream.TryWrite(.((uint8*)tmp.Ptr, tmp.Length)));

				if (len < tmp.Length)
					_stream.Position -= len - tmp.Length;

				if (_stream.Length - _stream.Position == 0)
				{
					delete _encodingStream; // To fill in the last bit
					CreateEncodingStream();
					_localStream.TryWrite(.((uint8*)CRLF.Ptr, CRLF.Length));
				}

				tmp.PrepareBuffer((int)(_localStream.Length - tmp.Length));
				tmp.Length = TrySilent!(_localStream.TryRead(.((uint8*)tmp.Ptr, (int)_localStream.Length)));
			}
			else if (_stream.Length - _stream.Position == 0)
			{
				tmp.Append(CRLF);
			}

			_buffer.Append(tmp);
		}

		public override void Reset()
		{
			base.Reset();
			_stream.Position = _originalPosition;
		}
	}

	public class MimeFileSection : MimeStreamSection
	{
		protected String _fileName = new .() ~ delete _;
		protected FileStream _fileStream = new .();

		public StringView FileName
		{
			[NoDiscard]
			get { return _fileName; }
			set
			{
				if (!_activated)
				{
					_fileName.Set(value);
					_stream = new FileStream();
					((FileStream)_stream).Open(value, .Read, .Read);
					SetContentType(value);
				}
			}
		}

		public this(Stream aOutputStream, StringView aFileName) : base(aOutputStream, new FileStream())
		{
			((FileStream)_stream).Open(aFileName, .Read, .Read);
			SetContentType(aFileName);
			Path.GetFileName(aFileName, _description);
			Encoding = .Base64;
			Path.GetFileName(aFileName, _fileName);
			_ownsStreams = true;
		}

		protected void SetContentType(StringView aFileName)
		{
			String tmp = scope .();
			Path.GetExtension(aFileName, tmp);
			tmp.Replace(".", "");

			if (
				tmp.Equals("bf", .OrdinalIgnoreCase)   ||
				tmp.Equals("c++", .OrdinalIgnoreCase)  ||
				tmp.Equals("cpp", .OrdinalIgnoreCase)  || tmp.Equals("cc", .OrdinalIgnoreCase) ||
				tmp.Equals("h", .OrdinalIgnoreCase)    || tmp.Equals("hh", .OrdinalIgnoreCase) ||
				tmp.Equals("pas", .OrdinalIgnoreCase)  || tmp.Equals("pp", .OrdinalIgnoreCase) ||
				tmp.Equals("pod", .OrdinalIgnoreCase)  ||
				tmp.Equals("php", .OrdinalIgnoreCase)  || tmp.Equals("php3", .OrdinalIgnoreCase) ||
				tmp.Equals("php4", .OrdinalIgnoreCase) || tmp.Equals("php5", .OrdinalIgnoreCase) ||
				tmp.Equals("pl", .OrdinalIgnoreCase)   ||
				tmp.Equals("rb", .OrdinalIgnoreCase)   ||
				tmp.Equals("txt", .OrdinalIgnoreCase)
			)
				_contentType.Set("text/plain");
			if (tmp.Equals("html", .OrdinalIgnoreCase) || tmp.Equals("shtml", .OrdinalIgnoreCase))
				_contentType.Set("text/html");
			if (tmp.Equals("css", .OrdinalIgnoreCase))
				_contentType.Set("text/css");

			if (tmp.Equals("png", .OrdinalIgnoreCase))
				_contentType.Set("image/x-png");
			if (tmp.Equals("xpm", .OrdinalIgnoreCase))
				_contentType.Set("image/x-pixmap");
			if (tmp.Equals("xbm", .OrdinalIgnoreCase))
				_contentType.Set("image/x-bitmap");
			if (tmp.Equals("tif", .OrdinalIgnoreCase) || tmp.Equals("tiff", .OrdinalIgnoreCase))
				_contentType.Set("image/tiff");
			if (tmp.Equals("mng", .OrdinalIgnoreCase))
				_contentType.Set("image/x-mng");
			if (tmp.Equals("gif", .OrdinalIgnoreCase))
				_contentType.Set("image/gif");
			if (tmp.Equals("rgb", .OrdinalIgnoreCase))
				_contentType.Set("image/rgb");
			if (tmp.Equals("jpg", .OrdinalIgnoreCase) || tmp.Equals("jpeg", .OrdinalIgnoreCase))
				_contentType.Set("image/jpeg");
			if (tmp.Equals("bmp", .OrdinalIgnoreCase))
				_contentType.Set("image/x-ms-bmp");

			if (tmp.Equals("wav", .OrdinalIgnoreCase))
				_contentType.Set("audio/x-wav");
			if (tmp.Equals("mp3", .OrdinalIgnoreCase))
				_contentType.Set("audio/x-mp3");
			if (tmp.Equals("ogg", .OrdinalIgnoreCase))
				_contentType.Set("audio/x-ogg");

			if (tmp.Equals("avi", .OrdinalIgnoreCase))
				_contentType.Set("video/x-msvideo");
			if (tmp.Equals("qt", .OrdinalIgnoreCase) || tmp.Equals("mov", .OrdinalIgnoreCase))
				_contentType.Set("video/quicktime");
			if (tmp.Equals("mpg", .OrdinalIgnoreCase) || tmp.Equals("mpeg", .OrdinalIgnoreCase))
				_contentType.Set("video/mpeg");

			if (tmp.Equals("pdf", .OrdinalIgnoreCase))
				_contentType.Set("application/pdf");
			if (tmp.Equals("rtf", .OrdinalIgnoreCase))
				_contentType.Set("application/rtf");
			if (tmp.Equals("tex", .OrdinalIgnoreCase))
				_contentType.Set("application/x-tex");
			if (tmp.Equals("latex", .OrdinalIgnoreCase))
				_contentType.Set("application/x-latex");
			if (tmp.Equals("doc", .OrdinalIgnoreCase))
				_contentType.Set("application/msword");
			if (tmp.Equals("gz", .OrdinalIgnoreCase))
				_contentType.Set("application/x-gzip");
			if (tmp.Equals("zip", .OrdinalIgnoreCase))
				_contentType.Set("application/zip");
			if (tmp.Equals("7z", .OrdinalIgnoreCase))
				_contentType.Set("application/x-7zip");
			if (tmp.Equals("rar", .OrdinalIgnoreCase))
				_contentType.Set("application/rar");
			if (tmp.Equals("tar", .OrdinalIgnoreCase))
				_contentType.Set("application/x-tar");
			if (tmp.Equals("arj", .OrdinalIgnoreCase))
				_contentType.Set("application/arj");
		}

		public override void GetHeader(String aOutStr)
		{
			aOutStr.Clear();
			aOutStr.AppendF(
				"Content-Type: {0}\r\nContent-Transfer-Encoding: {1}\r\nContent-Disposition: {2}\r\n; filename=\"{3}\"\r\n",
				_contentType, _encoding.StrVal, _disposition.StrVal, _fileName
			);

			if (_description.Length > 0)
				aOutStr.AppendF("Content-Description: {0}\r\n", _description);

			aOutStr.Append(CRLF);
		}
	}
}
