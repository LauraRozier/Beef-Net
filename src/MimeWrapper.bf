using System;
using System.IO;

namespace Beef_Net
{
	public enum MimeEncoding
	{
		case _8Bit;
		case Base64;

		public void ToString(String aOutStr)
		{
			switch (this)
			{
			case ._8Bit:  aOutStr.Set("8bit");
			case .Base64: aOutStr.Set("base64");
			}
		}
	}

	public enum MimeDisposition
	{
		case Inline;
		case Attachment;

		public void ToString(String aOutStr)
		{
			switch (this)
			{
			case .Inline:     aOutStr.Set("inline");
			case .Attachment: aOutStr.Set("attachment");
			}
		}
	}

	public enum MimeType
	{
		case Mixed;
		case Alternative;

		public void ToString(String aOutStr)
		{
			switch (this)
			{
			case .Mixed:       aOutStr.Set("mixed");
			case .Alternative: aOutStr.Set("alternative");
			}
		}
	}

	public abstract class MimeSection
	{
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
			/*
  Result := 0;

  if OriginalSize = 0 then
    Exit;
    
  case FEncoding of
    me8bit   : Result := OriginalSize;
    meBase64 : if OriginalSize mod 3 = 0 then
                 Result := (OriginalSize div 3) * 4 // this is simple, 4 bytes per 3 bytes
               else
                 Result := ((OriginalSize + 3) div 3) * 4; // add "padding" trupplet
  end;
			*/
			return 0;
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
			/*
  Result := 'Content-Type: ' + FContentType + CRLF;
  Result := Result + 'Content-Transfer-Encoding: ' + EncodingToStr(FEncoding) + CRLF;
  Result := Result + 'Content-Disposition: ' + DispositionToStr(FDisposition) + CRLF;

  if Length(FDescription) > 0 then
    Result := Result + 'Content-Description: ' + FDescription + CRLF;
    
  Result := Result + CRLF;
			*/
		}

		public Result<int> TryRead(int aSize)
		{
			/*
  Result := 0;

  if aSize <= 0 then
    Exit;

  if not FActivated then begin
    FActivated := True;
    FBuffer := GetHeader;
  end;
  
  if Length(FBuffer) < aSize then
    FillBuffer(aSize);
    
  s := ReadBuffer(aSize);
  if Length(s) >= aSize then begin
    Result := FOutputStream.Write(s[1], aSize);
    Delete(FBuffer, 1, Result);
  end else if Length(s) > 0 then begin
    Result := FOutputStream.Write(s[1], Length(s));
    Delete(FBuffer, 1, Result);
  end;
			*/
			return .Ok(0);
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
			/*
  if FActivated then
    Result := Length(FBuffer) + RecalculateSize(Length(FData))
  else
    Result := Length(FBuffer) + Length(GetHeader) + RecalculateSize(Length(FData));

  if not FActivated
  or (Length(FBuffer) > 0)
  or (Length(FData) > 0) then
    if Length(FOriginalData) > 0 then
      Result := Result + Length(CRLF); // CRLF after each msg body
			*/
			return 0;
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
			/*
  s := Copy(FData, 1, aSize);
  
  if Length(s) = 0 then
    Exit;
  
  n := aSize;

  if Assigned(FEncodingStream) then begin
    n := FEncodingStream.Write(s[1], Length(s));
    Delete(FData, 1, n);

    if Length(FData) = 0 then begin
      FEncodingStream.Free; // to fill in the last bit
      CreateEncodingStream;
      FLocalStream.Write(CRLF[1], Length(CRLF));
    end;
    
    SetLength(s, FLocalStream.Size);
    SetLength(s, FLocalStream.Read(s[1], Length(s)));
  end else begin
    Delete(FData, 1, n);
    if Length(FData) = 0 then
      s := s + CRLF;
  end;

  FBuffer := FBuffer + s;
			*/
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
			/*
  if FActivated then
    Result := Length(FBuffer) + RecalculateSize(FStream.Size - FStream.Position)
  else
    Result := Length(FBuffer) + Length(GetHeader) + RecalculateSize(FStream.Size - FStream.Position);
    
  if not FActivated
  or (Length(FBuffer) > 0)
  or (FStream.Size - FStream.Position > 0) then
    if FStream.Size - FOriginalPosition > 0 then
      Result := Result + Length(CRLF); // CRLF after each msg body
			*/
			return 0;
		}

		protected void SetStream(Stream aValue)
		{
			/*
  if Assigned(FStream)
  and FOwnsStreams then begin
    FStream.Free;
    FStream := nil;
  end;
  
  FStream := aValue;
  FOriginalPosition := FStream.Position;
			*/
		}

		protected override void FillBuffer(int aSize)
		{
			/*
  SetLength(s, aSize);
  SetLength(s, FStream.Read(s[1], aSize));
  
  if Length(s) <= 0 then
    Exit;
  
  if Assigned(FEncodingStream) then begin
    n := FEncodingStream.Write(s[1], Length(s));
    
    if n < Length(s) then
      FStream.Position := FStream.Position - (n - Length(s));
      
    if FStream.Size - FStream.Position = 0 then begin
      FEncodingStream.Free; // to fill in the last bit
      CreateEncodingStream;
      FLocalStream.Write(CRLF[1], Length(CRLF));
    end;
      
    SetLength(s, FLocalStream.Size);
    SetLength(s, FLocalStream.Read(s[1], FLocalStream.Size));
  end else if FStream.Size - FStream.Position = 0 then
    s := s + CRLF;

  FBuffer := FBuffer + s;
			*/
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
			/*
  s := StringReplace(ExtractFileExt(aFileName), '.', '', [rfReplaceAll]);

  if (s = 'txt')
  or (s = 'pas')
  or (s = 'pp')
  or (s = 'pl')
  or (s = 'cpp')
  or (s = 'cc')
  or (s = 'h')
  or (s = 'hh')
  or (s = 'rb')
  or (s = 'pod')
  or (s = 'php')
  or (s = 'php3')
  or (s = 'php4')
  or (s = 'php5')
  or (s = 'c++') then FContentType := 'text/plain';
  
  if (s = 'html')
  or (s = 'shtml') then FContentType := 'text/html';
  if s = 'css' then FContentType := 'text/css';
  
  if s = 'png' then FContentType := 'image/x-png';
  if s = 'xpm' then FContentType := 'image/x-pixmap';
  if s = 'xbm' then FContentType := 'image/x-bitmap';
  if (s = 'tif')
  or (s = 'tiff') then FContentType := 'image/tiff';
  if s = 'mng' then FContentType := 'image/x-mng';
  if s = 'gif' then FContentType := 'image/gif';
  if s = 'rgb' then FContentType := 'image/rgb';
  if (s = 'jpg')
  or (s = 'jpeg') then FContentType := 'image/jpeg';
  if s = 'bmp' then FContentType := 'image/x-ms-bmp';
    
  if s = 'wav' then FContentType := 'audio/x-wav';
  if s = 'mp3' then FContentType := 'audio/x-mp3';
  if s = 'ogg' then FContentType := 'audio/x-ogg';
  if s = 'avi' then FContentType := 'video/x-msvideo';
  if (s = 'qt')
  or (s = 'mov') then FContentType := 'video/quicktime';
  if (s = 'mpg')
  or (s = 'mpeg') then FContentType := 'video/mpeg';
  
  if s = 'pdf' then FContentType := 'application/pdf';
  if s = 'rtf' then FContentType := 'application/rtf';
  if s = 'tex' then FContentType := 'application/x-tex';
  if s = 'latex' then FContentType := 'application/x-latex';
  if s = 'doc' then FContentType := 'application/msword';
  if s = 'gz' then FContentType := 'application/x-gzip';
  if s = 'zip' then FContentType := 'application/zip';
  if s = '7z' then FContentType := 'application/x-7zip';
  if s = 'rar' then FContentType := 'application/rar';
  if s = 'tar' then FContentType := 'application/x-tar';
  if s = 'arj' then FContentType := 'application/arj';
			*/
		}

		public override void GetHeader(String aOutStr)
		{
			/*
  Result := 'Content-Type: ' + FContentType + CRLF;
  Result := Result + 'Content-Transfer-Encoding: ' + EncodingToStr(FEncoding) + CRLF;
  Result := Result + 'Content-Disposition: ' + DispositionToStr(FDisposition) +
            '; filename="' + FFileName + '"' + CRLF;

  if Length(FDescription) > 0 then
    Result := Result + 'Content-Description: ' + FDescription + CRLF;
    
  Result := Result + CRLF; 
			*/
		}
	}
}
