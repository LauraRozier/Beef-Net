using System;
using System.Collections;
using Beef_Net.Interfaces;

namespace Beef_Net
{
	abstract class Component : IComponent
	{
		protected StringView _host;
		protected uint16 _port;
		protected Component _creator;
		protected bool _active;

	    public Type SocketClass { get; set; }

	    public StringView Host
		{
			get { return _host; }
			set { _host = value; }
		}

	    public uint16 Port
		{
			get { return _port; }
			set { _port = value; }
		}

	    public Component Creator
		{
			get { return _creator; }
			set { SetCreator(value); }
		}

	    public bool Active
		{
			get { return _active; }
		}

		protected virtual void SetCreator(Component aValue)
		{

		}

		public this()
		{
			_creator = this;
		}

		public ~this()
		{
		}

		public abstract void Disconnect(bool aIndForced = false);

		public abstract void CallAction();
	}
}
