using System;
using System.Collections.Generic;
using System.ComponentModel.Design;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveForeignKeyOperation))]
	public sealed class AddForeignKeyOperation : ConstraintOperation
	{
		public AddForeignKeyOperation(string schemaName, string tableName, string name, string[] columnName,
			string referencesSchemaName,
			string referencesTableName, string[] referencesColumnName, string onDelete,
			string onUpdate, bool notForReplication, bool withNoCheck)
			: base(schemaName, tableName, name, ConstraintType.ForeignKey)
		{
			ColumnName = new List<string>(columnName);
			ReferencesSchemaName = referencesSchemaName;
			ReferencesTableName = referencesTableName;
			ReferencesColumnName = new List<string>(referencesColumnName);
			OnDelete = onDelete;
			OnUpdate = onUpdate;
			NotForReplication = notForReplication;
			WithNoCheck = withNoCheck;
		}


		public List<string> ColumnName { get; private set; }

		public string OnDelete { get; set; }

		public string OnUpdate { get; set; }

		public bool NotForReplication { get; set; }

		public string ReferencesSchemaName { get; set; }

		public string ReferencesTableName { get; set; }

		public string ReferencesTableObjectName => $"{ReferencesSchemaName}.{ReferencesTableName}";

		public List<string> ReferencesColumnName { get; private set; }

		public bool WithNoCheck { get; set; }

		private static bool RenameColumn(RenameColumnOperation renameOperation, List<string> columns)
		{
			for (var idx = 0; idx < columns.Count; ++idx)
			{
				var column = columns[idx];
				if (column.Equals(renameOperation.Name, StringComparison.InvariantCultureIgnoreCase))
				{
					columns[idx] = renameOperation.NewName;
					renameOperation.Disabled = true;
					return true;
				}
			}

			return false;
		}

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			if (operation is RenameColumnOperation otherAsRenameColumnOp)
			{
				if (TableObjectName.Equals(otherAsRenameColumnOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase) &&
					RenameColumn(otherAsRenameColumnOp, ColumnName))
					return MergeResult.Continue;

				if (ReferencesTableObjectName.Equals(otherAsRenameColumnOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase) &&
					RenameColumn(otherAsRenameColumnOp, ReferencesColumnName))
					return MergeResult.Continue;
			}

			if (operation is RenameObjectOperation otherAsRenameTableOp &&
				ReferencesTableObjectName.Equals(otherAsRenameTableOp.ObjectName, StringComparison.InvariantCultureIgnoreCase))
			{
				ReferencesTableName = otherAsRenameTableOp.NewName;
				otherAsRenameTableOp.Disabled = true;
				return MergeResult.Continue;
			}

			return MergeResult.Continue;
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'F') is null{Environment.NewLine}" +
				   $"    {ToQuery()}";
		}

		public override string ToQuery()
		{
			var sourceColumns = string.Join("],[", ColumnName.ToArray());
			var refColumns = string.Join("],[", ReferencesColumnName.ToArray());

			var onDeleteClause = "";
			if (!string.IsNullOrEmpty(OnDelete))
			{
				onDeleteClause = string.Format("on delete {0}", OnDelete);
			}

			var onUpdateClause = "";
			if (!string.IsNullOrEmpty(OnUpdate))
			{
				onUpdateClause = string.Format("on update {0}", OnUpdate);
			}

			var notForReplicationClause = "";
			if (NotForReplication)
			{
				notForReplicationClause = "not for replication";
			}

			var withNoCheckClause = "";
			if (WithNoCheck)
			{
				withNoCheckClause = " with nocheck";
			}

			return
				string.Format(
					"alter table [{0}].[{1}]{10} add constraint [{2}] foreign key ([{3}]) references [{4}].[{5}] ([{6}]) {7} {8} {9}",
					SchemaName, TableName, Name, sourceColumns, ReferencesSchemaName, ReferencesTableName,
					refColumns, onDeleteClause, onUpdateClause, notForReplicationClause, withNoCheckClause);
		}
	}
}
