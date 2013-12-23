using System;

namespace Rivet.Operations
{
	public sealed class RemoveDefaultConstraintOperation : TableObjectOperation
	{
		public RemoveDefaultConstraintOperation(string schemaName, string tableName, string columnName)
			: base(schemaName, tableName, new ConstraintName(schemaName, tableName, new[] { columnName }, ConstraintType.Default).ToString())
		{
			ColumnName = columnName;
		}

		public RemoveDefaultConstraintOperation(string schemaName, string tableName, string columnName, string name)
			: this(schemaName, tableName, columnName)
		{
			Name = new ConstraintName(name).ToString();
		}

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
