using System;

namespace Rivet.Operations
{
	public sealed class AddForeignKeyOperation : Operation
	{
		public AddForeignKeyOperation(string schemaName, string tableName, string[] columnName, string referencesSchemaName,
		                              string referencesTableName, string[] referencesColumnName, string onDelete,
		                              string onUpdate, bool notForReplication)
		{
			Cons = new ForeignConstraintName(schemaName, tableName, referencesSchemaName, referencesTableName);
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

		public ForeignConstraintName Cons { get; private set; }
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
			var source_columns = string.Join(",", ColumnName);
			var ref_columns = string.Join(",", ReferencesColumnName);

			var OnDeleteClause = "";
			if (!string.IsNullOrEmpty(OnDelete))
			{
				OnDeleteClause = string.Format("on delete {0}", OnDelete);
			}

			var OnUpdateClause = "";
			if (!string.IsNullOrEmpty(OnUpdate))
			{
				OnUpdateClause = string.Format("on update {0}", OnUpdate);
			}

			var NotForReplicationClause = "";
			if (NotForReplication)
			{
				NotForReplicationClause = "not for replication";
			}

			return string.Format("alter table [{0}].[{1}] add constraint {2} foreign key ({3}) references {4}.{5} ({6}) {7} {8} {9}", 
				SchemaName, TableName, Cons.ReturnConstraintName(), source_columns, ReferencesSchemaName, ReferencesTableName, 
				ref_columns, OnDeleteClause, OnUpdateClause, NotForReplicationClause);
		}
	}
}
