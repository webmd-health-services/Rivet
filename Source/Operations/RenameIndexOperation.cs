using System;

namespace Rivet.Operations
{
	public sealed class RenameIndexOperation : RenameTableObjectOperation
	{
		public RenameIndexOperation(string schemaName, string tableName, string name, string newName)
			: base(schemaName, tableName, name, newName, "INDEX")
		{
		}

		public override string ToIdempotentQuery()
		{
			return
				$"if exists (select * from sys.indexes where ([object_id] = object_id('{SchemaName}.{TableName}', 'U') or [object_id] = object_id('{SchemaName}.{TableName}', 'V')) and [name] = '{Name}') and{Environment.NewLine}" +
				$"   not exists (select * from sys.indexes where ([object_id] = object_id('{SchemaName}.{TableName}', 'U') or [object_id] = object_id('{SchemaName}.{TableName}', 'V')) and [name] = '{NewName}'){Environment.NewLine}" +
				$"begin{Environment.NewLine}" +
				$"    {ToIndentedQuery()}{Environment.NewLine}" +
				"end";
		}
	}
}
