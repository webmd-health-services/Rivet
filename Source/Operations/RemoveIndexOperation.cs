using System;

namespace Rivet.Operations
{
	public sealed class RemoveIndexOperation : Operation
	{
		public RemoveIndexOperation(string schemaName, string tableName, string[] columnName, ConstraintType type)
		{
			Name = new ConstraintName(schemaName, tableName, columnName, type);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
		}

		public RemoveIndexOperation(string schemaName, string tableName, string name)
		{
			Name = new ConstraintName(name);
			SchemaName = schemaName;
			TableName = tableName;
		}

		public ConstraintName Name { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string [] ColumnName { get; private set; }

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
