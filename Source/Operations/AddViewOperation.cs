using System;

namespace Rivet.Operations
{
	public sealed class AddViewOperation : Operation
	{
		public AddViewOperation(string schemaName, string name, string definition)
		{
			SchemaName = schemaName;
			Name = name;
			Definition = definition;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }
		public string Definition { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'V') is null{2}\t{0}exec sp_executesql N'{3}'", SchemaName, Name,
				Environment.NewLine, ToQuery().Replace("'", "''"));
		}

		public override string ToQuery()
		{
			return string.Format("create view [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}