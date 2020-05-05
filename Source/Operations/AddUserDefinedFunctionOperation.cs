using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveUserDefinedFunctionOperation))]
	public sealed class AddUserDefinedFunctionOperation : ObjectOperation
	{
		public AddUserDefinedFunctionOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

		public string Definition { get; set; }

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'AF') is null and{Environment.NewLine}" +
			       $"   object_id('{SchemaName}.{Name}', 'FN') is null and{Environment.NewLine}" +
			       $"   object_id('{SchemaName}.{Name}', 'TF') is null and{Environment.NewLine}" +
			       $"   object_id('{SchemaName}.{Name}', 'FS') is null and{Environment.NewLine}" +
			       $"   object_id('{SchemaName}.{Name}', 'FT') is null and{Environment.NewLine}" +
			       $"   object_id('{SchemaName}.{Name}', 'IF') is null{Environment.NewLine}" +
			       $"    exec sp_executesql N'{ToQuery().Replace("'", "''")}'";
		}

		public override string ToQuery()
		{
			return $"create function [{SchemaName}].[{Name}] {Definition}";
		}
	}
}