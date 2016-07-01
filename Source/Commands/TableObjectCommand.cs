using System.Management.Automation;

namespace Rivet.Commands
{
	public abstract class TableObjectCommand : SchemaObjectCommand
	{
		[Parameter(Mandatory = true,Position = 0)]
		public string TableName { get; set; }

	}
}
