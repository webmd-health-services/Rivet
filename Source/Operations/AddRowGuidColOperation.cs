using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveRowGuidColOperation))]
	public sealed class AddRowGuidColOperation : TableObjectOperation
	{
		public AddRowGuidColOperation(string schemaName, string tableName, string columnName) : base(schemaName, tableName, columnName)
		{
			ColumnName = columnName;
		}

		public string ColumnName { get; set; }

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			if (operation is RenameColumnOperation otherAsRenameColumnOp &&
				TableObjectName.Equals(otherAsRenameColumnOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase) &&
				ColumnName.Equals(otherAsRenameColumnOp.Name, StringComparison.InvariantCultureIgnoreCase))
			{
				ColumnName = otherAsRenameColumnOp.NewName;
				otherAsRenameColumnOp.Disabled = true;
				return MergeResult.Continue;
			}

			return MergeResult.Continue;
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] alter column [{ColumnName}] add rowguidcol";
		}

		public override string ToIdempotentQuery()
		{
			return $"if( exists(select * from sys.schemas s inner join sys.tables t on s.schema_id=t.schema_id inner join sys.columns c on c.object_id = t.object_id " +
				   $"where s.name = '{SchemaName}' and t.name = '{TableName}' and c.name = '{ColumnName}' and c.is_rowguidcol = 0) ){Environment.NewLine}\t{ToQuery()}";
		}
	}
}
