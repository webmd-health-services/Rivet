using System;

namespace Rivet.Operations
{
	public sealed class RenameIndexOperation : RenameOperation
	{
		public RenameIndexOperation(string schemaName, string tableName, string name, string newName)
			: base(schemaName, name, newName)
		{
			TableName = tableName;
		}

		public string TableName { get; private set; }

		public override string ToIdempotentQuery()
		{
			return
				String.Format(
					"if exists (select * from sys.indexes where ([object_id] = object_id('{0}.{1}', 'U') or [object_id] = object_id('{0}.{1}', 'V')) and [name] = '{2}') and not exists (select * from sys.indexes where ([object_id] = object_id('{0}.{1}', 'U') or [object_id] = object_id('{0}.{1}', 'V')) and [name] = '{3}'){4}begin{4}\t{5}{4}end",
					SchemaName, TableName, Name, NewName, Environment.NewLine, ToQuery());
		}

		protected override string GetRenameArguments()
		{
			return String.Format("'{0}.{1}.{2}', '{3}', 'INDEX'", SchemaName, TableName, Name, NewName);
		}
	}
}
