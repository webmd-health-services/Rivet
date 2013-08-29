using System;

namespace Rivet.Operations
{
	public sealed class AddForeignKeyOperation : Operation
	{
		public AddForeignKeyOperation(string schemaName, string tableName, string[] columnName, string referencesSchemaName,
		                              string referencesTableName, string[] referencesColumnName, string onDelete,
		                              string onUpdate, bool notForReplication)
		{
			ForeignKeyConstraintName = new ForeignKeyConstraintName(schemaName, tableName, referencesSchemaName, referencesTableName);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
			ReferencesSchemaName = referencesSchemaName;
			ReferencesTableName = referencesTableName;
			ReferencesColumnName = (string[])referencesColumnName.Clone();
			OnDelete = onDelete;
			OnUpdate = onUpdate;
			NotForReplication = notForReplication;
		}

		public ForeignKeyConstraintName ForeignKeyConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }
		public string ReferencesSchemaName { get; private set; }
		public string ReferencesTableName { get; private set; }
		public string[] ReferencesColumnName { get; private set; }
		public string OnDelete { get; private set; }
		public string OnUpdate { get; private set; }
		public bool NotForReplication { get; private set; }

		public override string ToQuery()
		{
			var sourceColumns = string.Join(",", ColumnName);
			var refColumns = string.Join(",", ReferencesColumnName);

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

			return string.Format("alter table [{0}].[{1}] add constraint {2} foreign key ({3}) references {4}.{5} ({6}) {7} {8} {9}", 
				SchemaName, TableName, ForeignKeyConstraintName.ToString(), sourceColumns, ReferencesSchemaName, ReferencesTableName, 
				refColumns, onDeleteClause, onUpdateClause, notForReplicationClause);
		}
	}
}
