using System;
using System.Collections;

namespace Beef_Net
{
#if BF_PLATFORM_LINUX
	static
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

		[CLink, CallingConvention(.Cdecl)]
		public extern static int32 epoll_create(int32 size);

		[CLink, CallingConvention(.Cdecl)]
		public extern static int32 epoll_ctl(int32 epfd, int32 op, int32 fd, EPoll_Event* event);

		[CLink, CallingConvention(.Cdecl)]
		public extern static int32 epoll_wait(int32 epfd, EPoll_Event* events, int32 maxevents, int32 timeout);
	}

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

	class EpollEventer : Eventer
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
			event.Events = EPOLLIN | EPOLLPRI | EPOLLHUP;

			if (!aHandle.IgnoreRead)
			{
			  	if (epoll_ctl(_epollReadFD, EPOLL_CTL_ADD, aHandle.[Friend]_handle, &event) < 0)
			    	Bail("Error modifying handle for reads", Common.SocketError());
			}
			else
			{
			  	if (epoll_ctl(_epollReadFD, EPOLL_CTL_DEL, aHandle.[Friend]_handle, &event) < 0)
			    	Bail("Error modifying handle for reads", Common.SocketError());
			}
		}

		protected void Inflate()
		{
		   	int oldLen = _events.Count;
			_events.Capacity = oldLen > 1 ? (int)Math.Sqrt((float)oldLen) : BASE_SIZE;
			_eventsRead.Capacity = _events.Capacity;
		}

		public this() : base()
		{
			_freeList = new List<Object>();
			Inflate();
			_timeout = 0;
			_epollFD = epoll_create(BASE_SIZE);
			_epollReadFD = epoll_create(BASE_SIZE);
			_epollMasterFD = epoll_create(2);

			if (_epollFD < 0 || _epollReadFD < 0 || _epollMasterFD < 0)
			{
				String tmp = scope .("Unable to create epoll: ");
				Common.StrError(Common.geterrno(), tmp);
				Runtime.FatalError(tmp);
			}

			EPoll_Event event = .();
			event.Events = EPOLLIN | EPOLLOUT | EPOLLPRI | EPOLLERR | EPOLLHUP | EPOLLET;
			event.Data.fd = _epollFD;

			if (epoll_ctl(_epollMasterFD, EPOLL_CTL_ADD, _epollFD, &event) < 0)
			{
				String tmp = scope .("Unable to add FDs to master epoll FD: ");
				Common.StrError(Common.geterrno(), tmp);
				Runtime.FatalError(tmp);
			}

			event.Data.fd = _epollReadFD;

			if (epoll_ctl(_epollMasterFD, EPOLL_CTL_ADD, _epollReadFD, &event) < 0)
			{
				String tmp = scope .("Unable to add FDs to master epoll FD: ");
				Common.StrError(Common.geterrno(), tmp);
				Runtime.FatalError(tmp);
			}
		}

		public ~this()
		{
			close(_epollReadFD);
			close(_epollMasterFD);
			close(_epollFD);
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
				event.Events = EPOLLET | EPOLLOUT | EPOLLERR;
				event.Data.ptr = &aHandle;

				if (epoll_ctl(_epollFD, EPOLL_CTL_ADD, aHandle.[Friend]_handle, &event) < 0)
					Bail("Error adding handle to epoll", Common.SocketError());

				event.Events = EPOLLIN | EPOLLPRI | EPOLLHUP;

				if (!aHandle.IgnoreRead)
					if (epoll_ctl(_epollReadFD, EPOLL_CTL_ADD, aHandle.[Friend]_handle, &event) < 0)
						Bail("Error adding handle to epoll", Common.SocketError());
					
				if (_count >= _events.Count)
					Inflate();
			}

			return result;
		}

		public override bool CallAction()
		{
			/*
			var
			  i, MasterChanges, Changes, ReadChanges: Integer;
			  Temp, TempRead: TLHandle;
			  MasterEvents: array[0..1] of TEpollEvent;
			begin
			  Result := False;
			  if FInLoop then
			    Exit;

			  Changes := 0;
			  ReadChanges := 0;

			  MasterChanges := epoll_wait(FEpollMasterFD, @MasterEvents[0], 2, FTimeout);

			  if MasterChanges > 0 then begin
			    for i := 0 to MasterChanges - 1 do
			      if MasterEvents[i].Data.fd = FEpollFD then
			        Changes := epoll_wait(FEpollFD, @FEvents[0], FCount, 0)
			      else
			        ReadChanges := epoll_wait(FEpollReadFD, @FEventsRead[0], FCount, 0);
			    if (Changes < 0) or (ReadChanges < 0) then
			      Bail('Error on epoll', LSocketError)
			    else
			      Result := Changes + ReadChanges > 0;

			    if Result then begin
			      FInLoop := True;
			      for i := 0 to Max(Changes, ReadChanges) - 1 do begin
			        Temp := nil;
			        if i < Changes then begin
			          Temp := TLHandle(FEvents[i].data.ptr);

			          if  (not Temp.FDispose)
			          and (FEvents[i].events and EPOLLOUT = EPOLLOUT) then
			            if Assigned(Temp.FOnWrite) and not Temp.IgnoreWrite then
			              Temp.FOnWrite(Temp);

			          if Temp.FDispose then
			            AddForFree(Temp);
			        end; // writes

			        if i < ReadChanges then begin
			          TempRead := TLHandle(FEventsRead[i].data.ptr);

			          if  (not TempRead.FDispose)
			          and ((FEventsRead[i].events and EPOLLIN = EPOLLIN)
			          or  (FEventsRead[i].events and EPOLLHUP = EPOLLHUP)
			          or  (FEventsRead[i].events and EPOLLPRI = EPOLLPRI)) then
			            if Assigned(TempRead.FOnRead) and not TempRead.IgnoreRead then
			              TempRead.FOnRead(TempRead);

			          if TempRead.FDispose then
			            AddForFree(TempRead);
			        end; // reads

			        if i < Changes then begin
			          if not Assigned(Temp) then
			            Temp := TLHandle(FEvents[i].data.ptr);

			          if  (not Temp.FDispose)
			          and (FEvents[i].events and EPOLLERR = EPOLLERR) then
			            if Assigned(Temp.FOnError) and not Temp.IgnoreError then
			              Temp.FOnError(Temp, 'Handle error' + LStrError(LSocketError));

			          if Temp.FDispose then
			            AddForFree(Temp);
			        end; // errors
			      end;
			      FInLoop := False;
			      if Assigned(FFreeRoot) then
			        FreeHandles;
			    end;
			  end else if MasterChanges < 0 then
			    Bail('Error on epoll', LSocketError);
			end;
			*/
		}
	}
#endif
}
