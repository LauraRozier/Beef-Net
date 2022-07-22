using System;
using System.Threading;

namespace Beef_Net
{
	public enum EventerType
	{
		EpollEventer,
		SelectEventer
	}

	public delegate void EventerErrorEvent(StringView aMsg, Eventer aSender);
	public delegate void HandleEvent(Handle aHandle);
	public delegate void HandleErrorEvent(Handle aHandle, StringView aMsg);

	public class Handle : IDisposable
	{
		protected fd_handle _handle = INVALID_SOCKET;
		protected Eventer _eventer;           // "queue holder"
		protected HandleEvent _onRead;
		protected HandleEvent _onWrite;
		protected HandleErrorEvent _onError;
		protected bool _ignoreWrite;         // so we can do edge-triggered
		protected bool _ignoreRead;          // so we can do edge-triggered
		protected bool _ignoreError;         // so we can do edge-triggered
		protected bool _isAcceptor;          // if socket was server-accepted
		protected bool _dispose;             // will free in the after-cycle
		protected bool _freeing;             // used to see if it's in the "to be freed" list
		protected Handle _prev;
		protected Handle _next;
		protected Handle _freeNext;
		protected void* _internalData;
		public void* UserData;

		public ref Handle Prev
		{
			get { return ref _prev; }
			set { _prev = value; }
		}
		public ref Handle Next
		{
			get { return ref _next; }
			set { _next = value; }
		}
		public ref Handle FreeNext
		{
			get { return ref _freeNext; }
			set { _freeNext = value; }
		}
		public bool IgnoreWrite
		{
			get { return _ignoreWrite; }
			set
			{
				if (_ignoreWrite != value)
				{
					_ignoreWrite = value;

					if (_eventer != null)
						_eventer.[Friend]HandleIgnoreWrite(this);
				}
			}
		}
		public bool IgnoreRead
		{
			get { return _ignoreRead; }
			set
			{
				if (_ignoreRead != value)
				{
					_ignoreRead = value;

					if (_eventer != null)
						_eventer.[Friend]HandleIgnoreError(this);
				}
			}
		}
		public bool IgnoreError
		{
			get { return _ignoreError; }
			set
			{
				if (_ignoreError != value)
				{
					_ignoreError = value;

					if (_eventer != null)
						_eventer.[Friend]HandleIgnoreError(this);
				}
			}
		}
		public HandleEvent OnRead
		{
			get { return _onRead; }
			set { _onRead = value; }
		}
		public HandleEvent OnWrite
		{
			get { return _onWrite; }
			set { _onWrite = value; }
		}
		public HandleErrorEvent OnError
		{
			get { return _onError; }
			set { _onError = value; }
		}
		public bool Dispose
		{
			get { return _dispose; }
			set { _dispose = value; }
		}
		public fd_handle Handle
		{
			get { return _handle; }
			set { _handle = value; }
		}
		public ref Eventer Eventer { get { return ref _eventer; } }

		public virtual this()
		{
			_onRead = null;
			_onWrite = null;
			_onError = null;
			UserData = null;
			_eventer = null;
			_prev = null;
			_next = null;
			_freeNext = null;
			_freeing = false;
			_dispose = false;
			_ignoreWrite = false;
			_ignoreRead = false;
			_ignoreError = false;
		}

		public ~this()
		{
			if (_eventer != null)
				_eventer.[Friend]InternalUnplugHandle(this);
		}

		public void Dispose()
		{
			Platform.BfpCritSect_Enter(CS);
			_dispose = true;

			if (_eventer != null && _eventer.[Friend]_inLoop)
				_eventer.[Friend]AddForFree(this);

			Platform.BfpCritSect_Leave(CS);
		}
	}

	public class Eventer
	{
	    protected Handle _root;
	    protected int32 _count;
	    protected EventerErrorEvent _onError;
	    protected int _references;
	    protected Handle _freeRoot; // the root of "free" list if any
	    protected Handle _freeIter; // the last of "free" list if any
	    protected bool _inLoop;

	    public int64 Timeout
		{
			get { return GetTimeout(); }
			set { SetTimeout(value); }
		}
	    public EventerErrorEvent OnError
		{
			get { return _onError; }
			set { _onError = value; }
		}
	    public int32 Count { get { return GetCount(); } }

		protected virtual int32 GetCount() =>
			_count;

		protected virtual int64 GetTimeout() =>
			0;

		protected virtual void SetTimeout(int64 aValue)
		{
		}

		protected bool Bail(StringView aMsg, int32 aErrNum)
		{
			if (_onError != null)
			{
				String errStr = scope .(aMsg);
				Common.StrError(aErrNum, errStr);
				_onError(errStr, this);
			}

			return false;
		}

		protected void AddForFree(Handle aHandle)
		{
			if (!aHandle.[Friend]_freeing)
			{
				aHandle.[Friend]_freeing = true;

				if (_freeIter == null)
				{
					_freeIter = aHandle;
					_freeRoot = aHandle;
				}
				else
				{
					_freeIter.FreeNext = aHandle;
					_freeIter = aHandle;
				}
			}
		}

		protected void FreeHandles()
		{
			Handle temp = _freeRoot;
			Handle temp2;

			while (temp != null)
			{
				temp2 = temp.FreeNext;
				delete temp;
				temp = temp2;
			}

			_freeRoot = null;
			_freeIter = null;
		}

		protected virtual void HandleIgnoreError(Handle aHandle)
		{
		}

		protected virtual void HandleIgnoreWrite(Handle aHandle)
		{
		}

		protected virtual void HandleIgnoreRead(Handle aHandle)
		{
		}

		protected void* GetInternalData(Handle aHandle) =>
			aHandle.[Friend]_internalData;

		protected void SetInternalData(Handle aHandle, void* aData) =>
			aHandle.[Friend]_internalData = aData;

		protected void SetHandleEventer(Handle aHandle) =>
			aHandle.[Friend]_eventer = this;

		protected virtual void InternalUnplugHandle(Handle aHandle)
		{
			if (aHandle.[Friend]_eventer == this)
			{
				if (aHandle.[Friend]_eventer.[Friend]_inLoop)
				{
					aHandle.[Friend]_eventer.AddForFree(aHandle);
					return;
				}
			
				aHandle.[Friend]_eventer = null; // avoid recursive AV

				if (aHandle.[Friend]_prev != null)
				{
					aHandle.[Friend]_prev.[Friend]_next = aHandle.[Friend]_next;

					if (aHandle.[Friend]_next != null)
						aHandle.[Friend]_next.[Friend]_prev = aHandle.[Friend]_prev;
				}
				else if (aHandle.[Friend]_next != null)
				{
					aHandle.[Friend]_next.[Friend]_prev = aHandle.[Friend]_prev;

					if (aHandle == _root)
						_root = aHandle.[Friend]_next;
				}
				else
				{
					_root = null;
				}

				if (_count > 0)
					_count--;
			}
		}

	    public virtual this()
		{
			_root = null;
			_freeRoot = null;
			_freeIter = null;
			_inLoop = false;
			_count = 0;
			_references = 1;
		}

	    public ~this()
		{
			Clear();
		}

	    public virtual bool AddHandle(Handle aHandle)
		{
			bool result = false;

			if (aHandle.[Friend]_eventer == null)
			{
				if (_root == null)
				{
					_root = aHandle;
				}
				else
				{
					if (_root.[Friend]_next != null)
					{
						_root.[Friend]_next.[Friend]_prev = aHandle;
						aHandle.[Friend]_next = _root.[Friend]_next;
					}

					_root.[Friend]_next = aHandle;
					aHandle.[Friend]_prev = _root;
				}

				aHandle.[Friend]_eventer = this;
				_count++;
				result = true;
			}

			return result;
		}

	    public virtual bool CallAction() =>
			true; // override in descendant

	    public virtual void RemoveHandle(Handle aHandle) =>
			aHandle.Dispose();

	    public void UnplugHandle(Handle aHandle)
		{
			Platform.BfpCritSect_Enter(CS);
			InternalUnplugHandle(aHandle);
			Platform.BfpCritSect_Leave(CS);
		}

	    public virtual void UnregisterHandle(Handle aHandle)
		{
			// do nothing, specific to win32 Eventer stuff (Why.. windows)
		}

	    public virtual void LoadFromEventer(Eventer aEventer)
		{
			Clear();
			_root = aEventer.[Friend]_root;
			_onError = aEventer.[Friend]_onError;
		}

	    public void Clear()
		{
			Handle temp = _root;
			Handle temp2;

			while (temp != null)
			{
				temp2 = temp;
				temp = temp2.[Friend]_next;
				temp2.Dispose();
			}

			_root = null;
		}

	    public void AddRef()
		{
			_references++;
		}

	    public void DeleteRef()
		{
			if (_references > 0)
				_references--;

			if (_references == 0)
				delete this;
		}
	}

	public class SelectEventer : Eventer
	{
		protected TimeVal _timeout;
		protected fd_set _readFDSet;
		protected fd_set _writeFDSet;
		protected fd_set _errorFDSet;
		
		protected override int64 GetTimeout() =>
			_timeout.tv_sec < 0 ? -1 : (_timeout.tv_sec * 1000) + (_timeout.tv_usec / 1000);

		protected override void SetTimeout(int64 aValue)
		{
			if (aValue >= 0)
			{
				_timeout.tv_sec = aValue / 1000;
				_timeout.tv_usec = (aValue % 1000) * 1000;
			}
			else
			{
				_timeout.tv_sec = -1;
				_timeout.tv_usec = 0;
			}
		}

		protected void ClearSets()
		{
			FD_ZERO(ref _readFDSet);
			FD_ZERO(ref _writeFDSet);
			FD_ZERO(ref _errorFDSet);
		}

	    public this() : base()
		{
			_timeout.tv_sec = 0;
			_timeout.tv_usec = 0;
		}

	    public override bool CallAction()
		{
			bool result = false;

			if (_inLoop)
				return result;
			
			if (_root == null)
			{
				Thread.Sleep((int32)(_timeout.tv_sec * 1000 + _timeout.tv_usec / 1000));
				return result;
			}
			
			_inLoop = true;
			Handle temp = _root;
			Handle temp2;
			fd_handle maxHandle = 0;
			ClearSets();
			
			while (temp != null)
			{
				if ((!temp.[Friend]_dispose) && ((!temp.IgnoreWrite) || (!temp.IgnoreRead) || (!temp.IgnoreError)))
				{
					if (!temp.IgnoreWrite)
						FD_SET(temp.[Friend]_handle, ref _writeFDSet);

					if (!temp.IgnoreRead)
						FD_SET(temp.[Friend]_handle, ref _readFDSet);

					if (!temp.IgnoreError)
						FD_SET(temp.[Friend]_handle, ref _errorFDSet);

					if (temp.[Friend]_handle > maxHandle)
						maxHandle = temp.[Friend]_handle;
				}
				
				temp2 = temp;
				temp = temp.[Friend]_next;

				if (temp2.[Friend]_dispose)
					temp2.Dispose();
			}

			TimeVal tempTime = _timeout;

			int n = _timeout.tv_sec >= 0
				? Common.Select((int)(maxHandle + 1), &_readFDSet, &_writeFDSet, &_errorFDSet, &tempTime)
				: Common.Select((int)(maxHandle + 1), &_readFDSet, &_writeFDSet, &_errorFDSet, null);
			
			if (n < 0)
				Bail("Error on select", Common.SocketError());

			result = n > 0;
			
			if (result)
			{
				temp = _root;

				while (temp != null)
				{
					if ((!temp.[Friend]_dispose) && FD_ISSET(temp.[Friend]_handle, ref _writeFDSet))
						if (temp.[Friend]_onWrite != null && !temp.IgnoreWrite)
							temp.[Friend]_onWrite(temp);

					if ((!temp.[Friend]_dispose) && FD_ISSET(temp.[Friend]_handle, ref _readFDSet))
						if (temp.[Friend]_onRead != null && !temp.IgnoreRead)
							temp.[Friend]_onRead(temp);

					if ((!temp.[Friend]_dispose) && FD_ISSET(temp.[Friend]_handle, ref _errorFDSet))
						if (temp.[Friend]_onError != null && !temp.IgnoreError)
						{
							String errStr = scope .("Handle error");
							Common.StrError(Common.SocketError(), errStr);
							temp.[Friend]_onError(temp, errStr);
						}

					temp2 = temp;
					temp = temp.[Friend]_next;

					if (temp2.[Friend]_dispose)
					{
						if (temp2 == _root)
							_root = null;

						temp2.Dispose();
						temp2.[Friend]_next = null;
					}
				}
			}
			
			_inLoop = false;
			
			if (_freeRoot != null)
				FreeHandles();

			return result;
		}
	}
}
