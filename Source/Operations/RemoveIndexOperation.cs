using System;

namespace Rivet.Operations
{
	public sealed class RemoveIndexOperation : TableObjectOperation
	{
		public RemoveIndexOperation(string schemaName, string tableName, string name, string[] columnName, bool unique)
			: base(schemaName, tableName, name)
		{
			ColumnName = columnName;
			Unique = unique;
		}

		public string[] ColumnName { get;  }

		public bool Unique { get; }

		public override string ToIdempotentQuery()
		{
			return $"if exists (select * from sys.indexes where name = '{Name}' and (object_id = object_id('{SchemaName}.{TableName}', 'U') or object_id = object_id('{SchemaName}.{TableName}', 'V'))){Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop index [{Name}] on [{SchemaName}].[{TableName}]";
		}
	}
}
