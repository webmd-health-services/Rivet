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
				$"if exists (select * from sys.columns where object_id('{SchemaName}.{TableName}', 'U') = [object_id] and [name]='{Name}') and{Environment.NewLine}" +
				$"   not exists (select * from sys.columns where object_id('{SchemaName}.{TableName}', 'U') = [object_id] and [name]='{NewName}'){Environment.NewLine}" +
				$"begin{Environment.NewLine}" +
				$"    {ToIndentedQuery()}{Environment.NewLine}" +
				"end";
		}
	}
}
