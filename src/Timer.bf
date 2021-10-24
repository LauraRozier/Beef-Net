using System;

namespace Beef_Net
{
	public delegate void NotifyEvent(Object aSender);

	public class Timer
	{
		// Units of time
		public const int HoursPerDay = 24;
		public const int MinsPerHour = 60;
		public const int SecsPerMin  = 60;
		public const int MSecsPerSec = 1000;
		public const int MinsPerDay  = HoursPerDay * MinsPerHour;
		public const int SecsPerDay  = MinsPerDay  * SecsPerMin;
		public const int SecsPerHour = SecsPerMin  * MinsPerHour;
		public const int MSecsPerDay = SecsPerDay  * MSecsPerSec;

		protected NotifyEvent _onTimer = null;
		protected TimeSpan _interval;
		protected DateTime _started;
		protected bool _oneShot;
		protected bool _enabled;

		public bool Enabled
		{
			get { return _enabled; }
			set { _enabled = value; }
		}
		public TimeSpan Interval
		{
			get { return _interval; }
			set
			{
				_interval = value;
				_started = DateTime.Now;
				_enabled = true;
			}
		}
		public bool OneShot
		{
			get { return _oneShot; }
			set { _oneShot = value; }
		}
		public NotifyEvent OnTimer
		{
			get { return _onTimer; }
			set { _onTimer = value; }
		}

		public void CallAction()
		{
			if (_enabled && _onTimer != null && (DateTime.Now - _started) >= _interval)
			{
				_onTimer(this);

				if (_oneShot)
					_enabled = false;
				else
					_started = DateTime.Now;
			}
		}
	}
}
