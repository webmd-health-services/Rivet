using System;

namespace Rivet.Operations
{
	public sealed class AddTriggerOperation : ObjectOperation
	{
		public AddTriggerOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

		public string Definition { get; set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}.{1}', 'TR') is null{2}\texec sp_executesql N'{3}'", SchemaName, Name, Environment.NewLine, ToQuery().Replace("'", "''"));
		}

		public override string ToQuery()
		{
			return string.Format("create trigger [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}