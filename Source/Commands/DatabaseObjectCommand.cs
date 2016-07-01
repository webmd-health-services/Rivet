using System.Management.Automation;

namespace Rivet.Commands
{
	public abstract class DatabaseObjectCommand : Cmdlet
	{
		[Parameter]
		public int Timeout { get; set; }

		protected abstract Operation CreateOperation();

		protected override void ProcessRecord()
		{
			base.ProcessRecord();

			var op = CreateOperation();

			if (MyInvocation.BoundParameters.ContainsKey("Timeout"))
			{
				op.CommandTimeout = Timeout;
			}

			WriteObject(op);
		}
	}
}
