using System;
using System.IO;
using System.Collections;

namespace Beef_Net
{
	public delegate void StreamNotificationEvent(int aSize);

	public class MimeStream : Stream
	{
		public static readonly StringView MIME_VERSION = "MIME-version: 1.0\r\n";
		public static readonly StringView MIME_HEADER = "Content-type: multipart/{0}; boundary=\"{1}\"\r\n\r\nThis is a multi-part message in MIME format.\r\n--{2}\r\n";

		private StreamNotificationEvent _doRead = new => DoRead ~ delete _;

	    protected MimeType _mimeType = .Mixed;
	    protected List<MimeSection> _sections = new .() ~ DeleteContainerAndItems!(_);
    	protected MimeOutputStream _outputStream = new .(_doRead) ~ delete _;
    	protected String _boundary = new .() ~ delete _;
    	protected int _activeSection = -1;
    	protected bool _calledRead = false;
    	protected bool _calledWrite = false;

		public int Count { get { return _sections.Count; } }
    	public StringView Boundary { get { return _boundary; } }
    	public MimeType MimeType
		{
			get { return _mimeType; }
			set { _mimeType = value; }
		}
		public override int64 Length
		{
			get
			{
				int64 result = 0;

				if (_activeSection > -2)
					for (int i = 0; i < _sections.Count; i++)
						result += _sections[i].Size;

				if (_activeSection == -1)
				{
					// Not yet active, must add header info
					String tmp = scope .();
					GetMimeHeader(tmp);
					result += tmp.Length + GetBoundarySize();
				}

				return result + _outputStream.Length;
			}
		}
		public override bool CanRead { get { return true; } }
		public override bool CanWrite { get { return true; } }
		public override int64 Position
		{
			get { return 0; }
			set { }
		}

    	protected void GetMimeHeader(String aOutStr)
		{
			aOutStr.Set(MIME_VERSION);

			if (_sections.Count > 1)
			{
				String tmp = scope .();
				_mimeType.ToString(tmp);
				aOutStr.AppendF(MIME_HEADER, tmp, _boundary, _boundary);
			}
		}

    	protected void GetBoundary(String aOutStr)
		{
			aOutStr.Clear();

			for (int i = 0; i < 25 + gRand.Next(15); i++)
				aOutStr.Append((char8)(gRand.Next((uint8)'9' - (uint8)'0' + 1) + (uint8)'0'));
		}

		protected int GetBoundarySize()
		{
			int result = 0;

			if (_sections.Count > 1)
			{
				int num = Math.Max(_activeSection, 0);
				result = (_boundary.Length + 4) * (_sections.Count - num) + 2;
				// # sections * (boundarylength + --CRLF +) ending --
			}

			return result;
		}

		protected void ActivateFirstSection()
		{
			if (_activeSection == -1 && _sections.Count > 0)
			{
				_activeSection = 0;
				String tmp = scope .();
				GetMimeHeader(tmp);
				_outputStream.TryWrite(.((uint8*)tmp.Ptr, tmp.Length));
			}
		}

		protected void ActivateNextSection()
		{
			String tmp = scope .();
			_activeSection++;

			if (_sections.Count > 1)
			{
				if (_activeSection >= _sections.Count)
					tmp.AppendF("--{0}--\r\n", _boundary);
				else
					tmp.AppendF("--{0}\r\n", _boundary);

				_outputStream.TryWrite(.((uint8*)tmp.Ptr, tmp.Length));
			}

			if (_activeSection >= _sections.Count)
				_activeSection = -2;
		}

		protected void DoRead(int aSize)
		{
			ActivateFirstSection();

			if (_activeSection < 0)
				return;

			_sections[_activeSection].TryRead(aSize);

			if (_sections[_activeSection].Size == 0)
				ActivateNextSection();
		}

		public this() : base()
		{
			GetBoundary(_boundary);
		}

		public MimeSection GetSection(int aIdx)
		{
			if (aIdx >= 0 && aIdx < _sections.Count)
				return _sections[aIdx];

			return null;
		}

		public void SetSection(int aIdx, MimeSection aValue)
		{
			if (aIdx >= 0 && aIdx < _sections.Count)
				_sections[aIdx] = aValue;
		}

		public override Result<int> TryRead(Span<uint8> data)
		{
			if (_sections.Count <= 0)
				return .Ok(0);

			if (_calledWrite)
				Runtime.FatalError("Already Called Write");

			_calledRead = true;
			return _outputStream.TryRead(data);
		}

		public override Result<int> TryWrite(Span<uint8> data)
		{
			if (_sections.Count <= 0)
				return .Ok(0);

			if (_calledRead)
				Runtime.FatalError("Already Called Read");

			_calledWrite = true;
			Runtime.NotImplemented("Not yet implemented");
#unwarn
			return _outputStream.TryWrite(data);
		}

	    public void AddTextSection(StringView aText, StringView aCharSet = "UTF-8")
		{
			if (_activeSection >= 0)
				Runtime.FatalError("Already Activated");

			MimeTextSection tmp = new .(_outputStream, aText);
			tmp.SetCharset(aCharSet);
			_sections.Add(tmp);
		}

	    public void AddFileSection(StringView aFileName)
		{
			if (_activeSection >= 0)
				Runtime.FatalError("Already Activated");

			_sections.Add(new MimeFileSection(_outputStream, aFileName));
		}

	    public void AddStreamSection(Stream aStream, bool aIndFreeStream = false)
		{
			if (_activeSection >= 0)
				Runtime.FatalError("Already Activated");

			MimeStreamSection tmp = new .(_outputStream, aStream);

			if (aIndFreeStream)
				tmp.OwnsStreams = true;

			_sections.Add(tmp);
		}

	    public void Delete(int aIdx)
		{
			if (aIdx >= 0 && aIdx < _sections.Count)
				_sections.RemoveAt(aIdx);
		}

	    public void Remove(MimeSection aSection) =>
			_sections.Remove(aSection);

	    public void Reset()
		{
			_calledRead = false;
			_calledWrite = false;

			for (int i = 0; i < _sections.Count; i++)
				_sections[i].Reset();

			_outputStream.Reset();
			_activeSection = -1;
		}

		public override Result<void> Seek(int64 pos, SeekKind seekKind = .Absolute) => .Ok;

		public override Result<void> Close() { return .Ok; }
	}

	public class MimeOutputStream : Stream
	{
		protected String _inputData = new .() ~ delete _;
		protected StreamNotificationEvent _notificationEvent = null;

		public override int64 Position
		{
			get { return 0; }
			set { }
		}
		public override int64 Length { get { return _inputData.Length; } }
		public override bool CanRead { get { return true; } }
		public override bool CanWrite { get { return true; } }

		public this(StreamNotificationEvent aNotificationEvent) : base()
		{
			_notificationEvent = aNotificationEvent;
		}

		protected void AddInputData(StringView aStr) =>
			_inputData.Append(aStr);

		public override Result<int> TryRead(Span<uint8> data)
		{
			if (_notificationEvent != null)
				_notificationEvent(data.Length);

			int result = Math.Min(data.Length, _inputData.Length);

			if (result <= 0)
				return .Ok(0);

			Internal.MemMove(data.Ptr, _inputData.Ptr, result);
			_inputData.Remove(0, result);
			return .Ok(result);
		}

		public override Result<int> TryWrite(Span<uint8> data)
		{
			String str = scope .(data.Length);
			Internal.MemMove(str.Ptr, data.Ptr, data.Length);
			AddInputData(str);
			return .Ok(data.Length);
		}

		public void Reset() =>
			_inputData.Clear();

		public override Result<void> Seek(int64 pos, SeekKind seekKind = .Absolute) => .Ok;

		public override Result<void> Close() { return .Ok; }
	}
}
