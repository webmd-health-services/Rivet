using System;

namespace Rivet.Operations
{
	public abstract class TableObjectOperation : Operation
	{
		protected TableObjectOperation(string schemaName, string tableName, string name) : base()
		{
			SchemaName = schemaName;
			TableName = tableName;
			Name = name;
		}

		public string Name { get; set; }

		public string ObjectName => $"{SchemaName}.{Name}";

		public override OperationQueryType QueryType => OperationQueryType.Ddl;

		public string SchemaName { get; set; }

		public string TableName { get; set; }

		public string TableObjectName => $"{SchemaName}.{TableName}";

		protected override MergeResult DoMerge(Operation operation)
        {
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			if (operation is TableObjectOperation otherAsTableObjectOp &&
				!TableObjectName.Equals(otherAsTableObjectOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase))
				return MergeResult.Stop;

			// The table this operation is a part of is getting removed so remove the operation.
			if (operation is RemoveTableOperation otherAsRemoveTableOp &&
				TableObjectName.Equals(otherAsRemoveTableOp.ObjectName, StringComparison.InvariantCultureIgnoreCase))
			{
				Disabled = true;
				return MergeResult.Stop;
			}

			if (operation is RenameObjectOperation otherAsRenameOp)
			{
				// If renaming a table, update objects that use that table.
				if (TableObjectName.Equals(otherAsRenameOp.ObjectName, StringComparison.InvariantCultureIgnoreCase))
				{
					TableName = otherAsRenameOp.NewName;
                    operation.Disabled = true;
					return MergeResult.Stop;
				}
			}

			return MergeResult.Continue;
		}
	}
}
