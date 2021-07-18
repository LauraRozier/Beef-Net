using System;
using System.Collections;
using System.Reflection;
using Beef_Net.Interfaces;

namespace Beef_Net
{
	abstract class Component : IComponent
	{
		protected String _host = new .() ~ delete _;
		protected uint16 _port = 0;
		protected Component _creator = null;
		protected bool _active = false;
		protected bool _isSSLSocket = false;

	    public bool IsSSLSocket
		{
			get { return _isSSLSocket; }
			set { _isSSLSocket = value; }
		}

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
