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
			return
				String.Format(
					"if exists (select * from sys.indexes where name = '{0}' and (object_id = object_id('{1}.{2}', 'U') or object_id = object_id('{1}.{2}', 'V'))){3}\t{4}",
					Name, SchemaName, TableName, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop index [{0}] on [{1}].[{2}]", Name, SchemaName, TableName);
		}
	}
}
