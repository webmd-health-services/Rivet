using System;

namespace Rivet.Operations
{
	public sealed class RemoveDefaultConstraintOperation : Operation
	{
		public RemoveDefaultConstraintOperation(string schemaName, string tableName, string columnName)
		{
			Name = new ConstraintName(schemaName, tableName, new[] { columnName }, ConstraintType.Default);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = columnName;
		}

		public RemoveDefaultConstraintOperation(string schemaName, string tableName, string columnName, string name)
		{
			Name = new ConstraintName(name);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = columnName;
		}

		public ConstraintName Name { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ColumnName { get; private set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}.{1}', 'D') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, Name);
		}
	}
}
