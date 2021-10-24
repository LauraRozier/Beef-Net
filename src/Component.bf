using Beef_Net.Interfaces;
using System;
using System.Collections;
using System.Reflection;

namespace Beef_Net
{
	abstract class Component : IComponent
	{
		protected String _host = new .() ~ delete _;
		protected uint16 _port = 0;
		protected Component _creator = null;
		protected bool _active = false;
		protected TypeInstance _socketClass = null;

	    public StringView Host
		{
			get { return _host; }
			set { _host.Set(value); }
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
	    public Type SocketClass
		{
			get { return _socketClass; }
			set { _socketClass = (TypeInstance)value; }
		}

		protected virtual void SetCreator(Component aValue)
		{
			_creator = aValue;
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
