using System;

namespace Rivet.Operations
{
	public sealed class RenameColumnOperation : RenameOperation
	{
		public RenameColumnOperation(string schemaName, string tableName, string name, string newName)
			: base(schemaName, name, newName, "COLUMN")
		{
			TableName = tableName;
		}

		public string TableName { get; private set; }

		public override string ToIdempotentQuery()
		{
			return
				string.Format(
					"if exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{2}') and not exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{3}'){4}begin{4}\t{5}{4}end",
					SchemaName, TableName, Name, NewName, Environment.NewLine, ToQuery());
		}

		protected override string GetObjectName()
		{
			return String.Format("{0}.{1}.{2}", SchemaName, TableName, Name);
		}

	}
}
