using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveViewOperation))]
	public sealed class AddViewOperation : ObjectOperation
	{
		public AddViewOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

		public string Definition { get; set; }

		public override string ToIdempotentQuery()
		{
			return
				$"if object_id('{SchemaName}.{Name}', 'V') is null{Environment.NewLine}" +
				$"    exec sp_executesql N'{ToQuery().Replace("'", "''")}'";
		}

		public override string ToQuery()
		{
			return $"create view [{SchemaName}].[{Name}] {Definition}";
		}
	}
}