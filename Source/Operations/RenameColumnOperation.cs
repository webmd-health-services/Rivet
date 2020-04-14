using System;

namespace Rivet.Operations
{
	public sealed class RenameColumnOperation : RenameTableObjectOperation
	{
		public RenameColumnOperation(string schemaName, string tableName, string name, string newName)
			: base(schemaName, tableName, name, newName, "COLUMN")
		{
		}

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			if (operation is RenameColumnOperation otherAsRenameColumnOp &&
				NewName.Equals(otherAsRenameColumnOp.Name, StringComparison.InvariantCultureIgnoreCase))
			{
				NewName = otherAsRenameColumnOp.NewName;
				otherAsRenameColumnOp.Disabled = true;
				return MergeResult.Continue;
			}

			return MergeResult.Continue;
		}

		public override string ToIdempotentQuery()
		{
			return
				string.Format(
					"if exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{2}') and not exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{3}'){4}begin{4}\t{5}{4}end",
					SchemaName, TableName, Name, NewName, Environment.NewLine, ToQuery());
		}
	}
}
