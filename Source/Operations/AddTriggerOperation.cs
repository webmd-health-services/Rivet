using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveTriggerOperation))]
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
			return
				$"if object_id('{SchemaName}.{Name}', 'TR') is null{Environment.NewLine}" +
				$"    exec sp_executesql N'{ToQuery().Replace("'", "''")}'";
		}

		public override string ToQuery()
		{
			return $"create trigger [{SchemaName}].[{Name}] {Definition}";
		}
	}
}