using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveStoredProcedureOperation))]
	public sealed class AddStoredProcedureOperation : ObjectOperation
	{
		public AddStoredProcedureOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

		public string Definition { get; set; }

		public override string ToIdempotentQuery()
		{
			return
				$"if object_id('{SchemaName}.{Name}', 'P') is null and object_id('{SchemaName}.{Name}', 'PC') is null{Environment.NewLine}" +
				$"    exec sp_executesql N'{ToQuery().Replace("'", "''")}'";
		}

		public override string ToQuery()
		{
			return $"create procedure [{SchemaName}].[{Name}] {Definition}";
		}
	}
}