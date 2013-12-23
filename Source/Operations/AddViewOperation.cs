using System;

namespace Rivet.Operations
{
	public sealed class AddViewOperation : ObjectOperation
	{
		public AddViewOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

		public string Definition { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'V') is null{2}\texec sp_executesql N'{3}'", SchemaName, Name,
				Environment.NewLine, ToQuery().Replace("'", "''"));
		}

		public override string ToQuery()
		{
			return string.Format("create view [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}