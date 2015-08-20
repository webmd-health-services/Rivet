﻿using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddForeignKeyOperation : ConstraintOperation
	{
		// System Generated Constraint Name
		public AddForeignKeyOperation(string schemaName, string tableName, string[] columnName, string referencesSchemaName,
		                              string referencesTableName, string[] referencesColumnName, string onDelete,
		                              string onUpdate, bool notForReplication, bool withNoCheck)
			: base(schemaName, tableName, new ForeignKeyConstraintName(schemaName, tableName, referencesSchemaName, referencesTableName).ToString(), ConstraintType.ForeignKey)
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

		//Custom Constraint Name
		public AddForeignKeyOperation(string schemaName, string tableName, string[] columnName, string referencesSchemaName,
							  string referencesTableName, string[] referencesColumnName, string name, string onDelete,
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
		public string ReferencesSchemaName { get; set; }
		public string ReferencesTableName { get; set; }
		public List<string> ReferencesColumnName { get; private set; }
		public string OnDelete { get; set; }
		public string OnUpdate { get; set; }
		public bool NotForReplication { get; set; }
		public bool WithNoCheck { get; set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'F') is null{2}\t{3}", SchemaName,Name, Environment.NewLine, ToQuery());
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
