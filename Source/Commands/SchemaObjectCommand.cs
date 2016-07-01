using System.Management.Automation;

namespace Rivet.Commands
{
	public abstract class SchemaObjectCommand : DatabaseObjectCommand
	{
		protected SchemaObjectCommand() : base()
		{
			SchemaName = "dbo";
		}

		[Parameter]
		public string SchemaName { get; set; }
	}
}
