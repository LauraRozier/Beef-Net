using System;
using System.Collections;

namespace Beef_Net
{
#if BF_PLATFORM_LINUX
	[CRepr, Union]
	public struct EPoll_Data
	{
		public void* ptr;
		public int32 fd;
		public uint32 u32;
		public uint64 u64;
	}

	#if BF_64_BIT
	[CRepr, Packed]
	#else // BF_32_BIT
	[CRepr]
	#endif // BF_.._BIT
	public struct EPoll_Event
	{
		public uint32 Events;
		public EPoll_Data Data;
	}

	public sealed static class EPoll
	{
		public const uint32 BASE_SIZE = 100;

		public const uint32 EPOLL_CTL_ADD = 1;
		public const uint32 EPOLL_CTL_DEL = 2;
		public const uint32 EPOLL_CTL_MOD = 3;

		public const uint32 EPOLLIN      = 0x01;    // The associated file is available for read(2) operations.
		public const uint32 EPOLLPRI     = 0x02;    // There is urgent data available for read(2) operations.
		public const uint32 EPOLLOUT     = 0x04;    // The associated file is available for write(2) operations.
		public const uint32 EPOLLERR     = 0x08;    // Error condition happened on the associated file descriptor.
		public const uint32 EPOLLHUP     = 0x10;    // Hang up happened on the associated file descriptor.
		public const uint32 EPOLLONESHOT = 1 << 30;
		public const uint32 EPOLLET      = 1 << 31; // Sets the Edge Triggered behavior for the associated file descriptor.

		[CLink, CallingConvention(.Cdecl)]
		public extern static int32 close(int32 fd);

		[LinkName("epoll_create"), CallingConvention(.Cdecl)]
		public extern static int32 create(int32 size);

		[LinkName("epoll_ctl"), CallingConvention(.Cdecl)]
		public extern static int32 ctl(int32 epfd, int32 op, int32 fd, EPoll_Event* event);

		[LinkName("epoll_wait"), CallingConvention(.Cdecl)]
		public extern static int32 wait(int32 epfd, EPoll_Event* events, int32 maxevents, int32 timeout);
	}

	public class EpollEventer : Eventer
	{
		protected int64 _timeout;
		protected List<EPoll_Event> _events = new .() ~ delete _;
		protected List<EPoll_Event> _eventsRead = new .() ~ delete _;
		protected int32 _epollReadFD;   // this one monitors LT style for READ
		protected int32 _epollFD;       // this one monitors ET style for other
		protected int32 _epollMasterFD; // this one monitors the first two
		protected List<Object> _freeList;
		
		protected override int64 GetTimeout() =>
			_timeout;

		protected override void SetTimeout(int64 aValue) =>
			_timeout = aValue >= 0 ? aValue : -1;

		protected override void HandleIgnoreRead(Handle aHandle)
		{
			var aHandle;
			EPoll_Event event = .();
			event.Data.ptr = &aHandle;
			event.Events = EPoll.EPOLLIN | EPoll.EPOLLPRI | EPoll.EPOLLHUP;

			if (!aHandle.IgnoreRead)
			{
			  	if (EPoll.ctl(_epollReadFD, EPoll.EPOLL_CTL_ADD, aHandle.[Friend]_handle, &event) < 0)
			    	Bail("Error modifying handle for reads", Common.SocketError());
			}
			else
			{
			  	if (EPoll.ctl(_epollReadFD, EPoll.EPOLL_CTL_DEL, aHandle.[Friend]_handle, &event) < 0)
			    	Bail("Error modifying handle for reads", Common.SocketError());
			}
		}

		protected void Inflate()
		{
		   	int oldLen = _events.Count;
			_events.Capacity = oldLen > 1 ? (int)Math.Sqrt((float)oldLen) : EPoll.BASE_SIZE;
			_eventsRead.Capacity = _events.Capacity;
		}

		public this() : base()
		{
			_freeList = new List<Object>();
			Inflate();
			_timeout = 0;
			_epollFD = EPoll.create(EPoll.BASE_SIZE);
			_epollReadFD = EPoll.create(EPoll.BASE_SIZE);
			_epollMasterFD = EPoll.create(2);

			if (_epollFD < 0 || _epollReadFD < 0 || _epollMasterFD < 0)
			{
				String tmp = scope .("Unable to create epoll: ");
				Common.StrError(Common.geterrno(), tmp);
				Runtime.FatalError(tmp);
			}

			EPoll_Event event = .();
			event.Events = EPoll.EPOLLIN | EPoll.EPOLLOUT | EPoll.EPOLLPRI | EPoll.EPOLLERR | EPoll.EPOLLHUP | EPoll.EPOLLET;
			event.Data.fd = _epollFD;

			if (EPoll.ctl(_epollMasterFD, EPoll.EPOLL_CTL_ADD, _epollFD, &event) < 0)
			{
				String tmp = scope .("Unable to add FDs to master epoll FD: ");
				Common.StrError(Common.geterrno(), tmp);
				Runtime.FatalError(tmp);
			}

			event.Data.fd = _epollReadFD;

			if (EPoll.ctl(_epollMasterFD, EPoll.EPOLL_CTL_ADD, _epollReadFD, &event) < 0)
			{
				String tmp = scope .("Unable to add FDs to master epoll FD: ");
				Common.StrError(Common.geterrno(), tmp);
				Runtime.FatalError(tmp);
			}
		}

		public ~this()
		{
			EPoll.close(_epollReadFD);
			EPoll.close(_epollMasterFD);
			EPoll.close(_epollFD);
			DeleteContainerAndItems!(_freeList);
			_freeList = null;
		}

		public override bool AddHandle(Handle aHandle)
		{
			var aHandle;
			bool result = base.AddHandle(aHandle);

			if (result)
			{
				result = false;
				EPoll_Event event = .();
				event.Events = EPoll.EPOLLET | EPoll.EPOLLOUT | EPoll.EPOLLERR;
				event.Data.ptr = &aHandle;

				if (EPoll.ctl(_epollFD, EPoll.EPOLL_CTL_ADD, aHandle.[Friend]_handle, &event) < 0)
					Bail("Error adding handle to epoll", Common.SocketError());

				event.Events = EPoll.EPOLLIN | EPoll.EPOLLPRI | EPoll.EPOLLHUP;

				if (!aHandle.IgnoreRead)
					if (EPoll.ctl(_epollReadFD, EPoll.EPOLL_CTL_ADD, aHandle.[Friend]_handle, &event) < 0)
						Bail("Error adding handle to epoll", Common.SocketError());
					
				if (_count >= _events.Count)
					Inflate();
			}

			return result;
		}

		public override bool CallAction()
		{
			if (_inLoop)
				return false;
	
			bool result = false;
			EPoll_Event[] masterEvents = scope EPoll_Event[2](?);
			int changes = 0;
			int readChanges = 0;

			int masterChanges = EPoll.wait(_epollMasterFD, &masterEvents[0], 2, (int32)_timeout);

			if (masterChanges > 0)
			{
				for (int i = 0; i < masterChanges; i++)
				{
			      	if (masterEvents[i].Data.fd == _epollFD)
			        	changes = EPoll.wait(_epollFD, &_events[0], _count, 0);
			      	else
			        	readChanges = EPoll.wait(_epollReadFD, &_eventsRead[0], _count, 0);
				}

			    if (changes < 0 || readChanges < 0)
			      	Bail("Error on epoll", Common.SocketError());
			    else
			      	result = changes + readChanges > 0;

			    if (result)
				{
			      	_inLoop = true;
					Handle temp, tempRead;

			      	for (int i = 0; i < Math.Max(changes, readChanges); i++)
					{
						temp = null;

						if (i < changes)
						{
						  	temp = *(Handle*)_events[i].Data.ptr;

						  	if  ((!temp.[Friend]_dispose) && _events[i].Events & EPoll.EPOLLOUT == EPoll.EPOLLOUT)
						    	if (temp.[Friend]_onWrite != null && !temp.IgnoreWrite)
						      		temp.[Friend]_onWrite(temp);

						  	if (temp.[Friend]_dispose)
						    	AddForFree(temp);
						} // writes

						if (i < readChanges)
						{
						  	tempRead = *(Handle*)_eventsRead[i].Data.ptr;

						  	if ((!tempRead.[Friend]_dispose) && (
								(_eventsRead[i].Events & EPoll.EPOLLIN == EPoll.EPOLLIN) ||
								(_eventsRead[i].Events & EPoll.EPOLLHUP == EPoll.EPOLLHUP) ||
								(_eventsRead[i].Events & EPoll.EPOLLPRI == EPoll.EPOLLPRI)
							))
						    	if (tempRead.[Friend]_onRead != null && !tempRead.IgnoreRead)
						      		tempRead.[Friend]_onRead(tempRead);

						  	if (tempRead.[Friend]_dispose)
						    	AddForFree(tempRead);
						} // reads

						if (i < changes)
						{
						  	if (temp == null)
						    	temp = *(Handle*)_events[i].Data.ptr;

						  	if ((!temp.[Friend]_dispose) && (_events[i].Events & EPoll.EPOLLERR == EPoll.EPOLLERR))
						    	if (temp.[Friend]_onError != null && !temp.IgnoreError)
								{
									String tmpStr = scope .("Handle error");
									Common.StrError(Common.SocketError(), tmpStr);
						      		temp.[Friend]_onError(temp, tmpStr);
								}

						  	if (temp.[Friend]_dispose)
						    	AddForFree(temp);
						} // errors
					}

			      	_inLoop = false;

					if (_freeRoot != null)
			        	FreeHandles();
				}
			}
			else if (masterChanges < 0)
			{		
		    	Bail("Error on epoll", Common.SocketError());
			}

			return result;
		}
	}
#else
	public class EpollEventer : Eventer
	{
	}
#endif
}
