using System;

namespace Beef_Net
{
	class Session
	{
		protected bool _active;

		public bool Active
		{
			get { return _active; }
		}

		/*
		public void RegisterWithComponent(aConnection: TLConnection);
		{
			if not Assigned(aConnection) then
				raise Exception.Create('Cannot register session with nil connection');
		}
		*/

		public void InitHandle(Handle aHandle) =>
			((Socket)aHandle).[Friend]_session = this;

		public void ReceiveEvent(Handle aHandle)
		{
			_active = true;
			CallReceiveEvent(aHandle);
		}

		public void SendEvent(Handle aHandle)
		{
			_active = true;
			CallSendEvent(aHandle);
		}

		public void ErrorEvent(Handle aHandle, StringView aMsg)
		{
			_active = true;
			CallErrorEvent(aHandle, aMsg);
		}

		public void ConnectEvent(Handle aHandle)
		{
			_active = true;
			CallConnectEvent(aHandle);
		}

		public void AcceptEvent(Handle aHandle)
		{
			_active = true;
			CallAcceptEvent(aHandle);
		}

		public void DisconnectEvent(Handle aHandle)
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
