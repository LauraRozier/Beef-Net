using Beef_Net.Connection;
using System;

namespace Beef_Net
{
	class Session
	{
		protected bool _active;

		public bool Active { get { return _active; } }

		public virtual void RegisterWithComponent(BaseConnection aConnection) =>
			Runtime.Assert(aConnection != null, "Cannot register session with null connection");

		public virtual void InitHandle(Handle aHandle) =>
			((Socket)aHandle).[Friend]_session = this;

		public virtual void ReceiveEvent(Handle aHandle)
		{
			_active = true;
			CallReceiveEvent(aHandle);
		}

		public virtual void SendEvent(Handle aHandle)
		{
			_active = true;
			CallSendEvent(aHandle);
		}

		public virtual void ErrorEvent(Handle aHandle, StringView aMsg)
		{
			_active = true;
			CallErrorEvent(aHandle, aMsg);
		}

		public virtual void ConnectEvent(Handle aHandle)
		{
			_active = true;
			CallConnectEvent(aHandle);
		}

		public virtual void AcceptEvent(Handle aHandle)
		{
			_active = true;
			CallAcceptEvent(aHandle);
		}

		public virtual void DisconnectEvent(Handle aHandle)
		{
			_active = true;
			CallDisconnectEvent(aHandle);
		}

		[Inline]
		public void CallReceiveEvent(Handle aHandle) =>
			((Socket)aHandle).[Friend]_connection.[Friend]ReceiveEvent((Socket)aHandle);

		[Inline]
		public void CallSendEvent(Handle aHandle) =>
			((Socket)aHandle).[Friend]_connection.[Friend]CanSendEvent((Socket)aHandle);
		
		[Inline]
		public void CallErrorEvent(Handle aHandle, StringView aMsg) =>
			((Socket)aHandle).[Friend]_connection.[Friend]ErrorEvent((Socket)aHandle, aMsg);
		
		[Inline]
		public void CallConnectEvent(Handle aHandle) =>
			((Socket)aHandle).[Friend]_connection.[Friend]ConnectEvent((Socket)aHandle);
		
		[Inline]
		public void CallAcceptEvent(Handle aHandle) =>
			((Socket)aHandle).[Friend]_connection.[Friend]AcceptEvent((Socket)aHandle);
		
		[Inline]
		public void CallDisconnectEvent(Handle aHandle) =>
			((Socket)aHandle).[Friend]_connection.[Friend]DisconnectEvent((Socket)aHandle);
	}
}
