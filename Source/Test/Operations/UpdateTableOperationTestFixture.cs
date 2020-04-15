using System;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateTableOperationTestFixture
	{
		private const string SchemaName = "schemaName";
		private const string Name = "name";
		private const string DefaultConstraintName = "default constraint name";
		static Column column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", DefaultConstraintName, "varchar column");
		static Identity identity = new Identity();
		static Column column2 = Column.Int("int column", identity, "test int column");
		private Column[] addColumnList = { column1, column2 };
		private Column[] updateColumnList = {column2, column1};
		private string[] removeColumnList = new string[] {"column 3", "column 4"};

		[Test]
		public void ShouldSetPropertiesForUpdateTable()
		{
			var op = new UpdateTableOperation(SchemaName, Name, addColumnList, updateColumnList, removeColumnList);

			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(addColumnList, op.AddColumns);
			Assert.AreEqual(updateColumnList, op.UpdateColumns);
			Assert.That(op.RemoveColumns, Is.EqualTo(removeColumnList));
			Assert.That(op.ObjectName, Is.EqualTo($"{SchemaName}.{Name}"));
		}

		[Test]
		public void ShouldWriteQueryForUpdateTableWithAddOnly()
		{
			var op = new UpdateTableOperation(SchemaName, Name, addColumnList, null, null);

			var expectedQuery =
				$"alter table [schemaName].[name] add [name] varchar(50) not null constraint [{DefaultConstraintName}] default ''{Environment.NewLine}" + 
				"alter table [schemaName].[name] add [int column] int identity not null";

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForUpdateTableWithUpdateOnly()
		{
			var op = new UpdateTableOperation(SchemaName, Name, null, updateColumnList, null);

			var expectedQuery =
				$"alter table [schemaName].[name] alter column [int column] int identity not null{Environment.NewLine}" + 
				$"alter table [schemaName].[name] alter column [name] varchar(50) not null constraint [{DefaultConstraintName}] default ''";

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForUpdateTableWithRemoveOnly()
		{
			var op = new UpdateTableOperation(SchemaName, Name, null, null, removeColumnList);

			var expectedQuery = 
				string.Format("alter table [schemaName].[name] drop column [column 3]{0}alter table [schemaName].[name] drop column [column 4]", Environment.NewLine);

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForUpdateTableWithAddUpdateRemove()
		{
			var op = new UpdateTableOperation(SchemaName, Name, addColumnList, updateColumnList, removeColumnList);

			var expectedQuery =
				$"alter table [schemaName].[name] add [name] varchar(50) not null constraint [{DefaultConstraintName}] default ''{Environment.NewLine}" +
				$"alter table [schemaName].[name] add [int column] int identity not null{Environment.NewLine}" +
				$"alter table [schemaName].[name] alter column [int column] int identity not null{Environment.NewLine}" + 
				$"alter table [schemaName].[name] alter column [name] varchar(50) not null constraint [{DefaultConstraintName}] default ''{Environment.NewLine}" + 
				$"alter table [schemaName].[name] drop column [column 3]{Environment.NewLine}alter table [schemaName].[name] drop column [column 4]";

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldRemoveDefaultExpressionFromAddedColumnsAndDisableRemovedDefaultConstraint()
		{
			var columns = new Column[]
			{
				Column.Int("column1", Nullable.NotNull, null, null, null),
				Column.Int("column2", Nullable.NotNull, null, null, null),
			};
			var op = new UpdateTableOperation("schema", "tableName", columns, new Column[0], new string[0]);
			var removeDefaultConstraintOp = new RemoveDefaultConstraintOperation("SCHEMA", "TABLENAME", "COLUMN2", "name");
			op.Merge(removeDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(removeDefaultConstraintOp.Disabled, Is.True);
			Assert.That(op.AddColumns[1].DefaultExpression, Is.Null);
		}

		[Test]
		public void ShouldRemoveDefaultExpressionFromUpdatedColumnsAndDisableRemovedDefaultConstraint()
		{
			var columns = new Column[]
			{
				Column.Int("column1", Nullable.NotNull, "defaultExpression", DefaultConstraintName, "description"),
				Column.Int("column2", Nullable.NotNull, "defaultExpression", DefaultConstraintName, "description"),
			};
			var op = new UpdateTableOperation("schema", "table Name", new Column[0], columns, new string[0]);
			var removeDefaultConstraintOp = new RemoveDefaultConstraintOperation("SCHEMA", "TABLE NAME", "COLUMN2", "name");
			op.Merge(removeDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(removeDefaultConstraintOp.Disabled, Is.True);
			Assert.That(op.UpdateColumns[1].DefaultExpression, Is.Null);
		}

		[Test]
		public void ShouldAddDefaultExpressionAndConstraintNameToAddedColumnsAndDisableAddDefaultConstraint()
		{
			var columns = new[]
			{
				Column.Int("column1", Nullable.NotNull, null, null, "description"),
				Column.Int("column2", Nullable.NotNull, null, null, "description"),
			};
			var op = new UpdateTableOperation("schema", "table", columns, new Column[0], new string[0]);
			var addDefaultConstraintOp =
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "NAME", "COLUMN2", "expression", false);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.True);
			Assert.That(op.AddColumns[0].DefaultExpression, Is.Null);
			Assert.That(op.AddColumns[0].DefaultConstraintName, Is.Null);
			Assert.That(op.AddColumns[1].DefaultExpression, Is.EqualTo("expression"));
			Assert.That(op.AddColumns[1].DefaultConstraintName, Is.EqualTo("NAME"));
		}

		[Test]
		public void ShouldAddDefaultExpressionToUpdatedColumnsAndDisableAddDefaultConstraint()
		{
			var columns = new[]
			{
				Column.Int("column1", Nullable.NotNull, null, null, "description"),
				Column.Int("column2", Nullable.NotNull, null, null, "description"),
			};
			var op = new UpdateTableOperation("schema", "table", new Column[0], columns, new string[0]);
			var addDefaultConstraintOp =
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "NAME", "COLUMN2", "expression", false);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.True);
			Assert.That(op.UpdateColumns[0].DefaultExpression, Is.Null);
			Assert.That(op.UpdateColumns[0].DefaultConstraintName, Is.Null);
			Assert.That(op.UpdateColumns[1].DefaultExpression, Is.EqualTo("expression"));
			Assert.That(op.UpdateColumns[1].DefaultConstraintName, Is.EqualTo("NAME"));
		}

		[Test]
		public void ShouldNotAddDefaultExpressionAndConstraintNameToAddedColumnsWhenDefaultConstraintWithValues()
		{
			var columns = new Column[]
			{
				Column.Int("column1", Nullable.NotNull, null, null, "description"),
				Column.Int("column2", Nullable.NotNull, null, null, "description"),
			};
			var op = new UpdateTableOperation("schema", "table", columns, new Column[0], new string[0]);
			var addDefaultConstraintOp =
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "NAME", "COLUMN2", "expression", true);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.False);
			Assert.That(op.AddColumns[0].DefaultExpression, Is.Null);
			Assert.That(op.AddColumns[0].DefaultConstraintName, Is.Null);
			Assert.That(op.AddColumns[1].DefaultExpression, Is.Null);
			Assert.That(op.AddColumns[1].DefaultConstraintName, Is.Null);
		}

		[Test]
		public void ShouldNotAddDefaultExpressionToUpdatedColumnsWhenDefaultConstraintWithValues()
		{
			var columns = new Column[]
			{
				Column.Int("column1", Nullable.NotNull, null, null, "description"),
				Column.Int("column2", Nullable.NotNull, null, null, "description"),
			};
			var op = new UpdateTableOperation("schema", "table", new Column[0], columns, new string[0]);
			var addDefaultConstraintOp =
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "NAME", "COLUMN2", "expression", true);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.False);
			Assert.That(op.UpdateColumns[0].DefaultExpression, Is.Null);
			Assert.That(op.UpdateColumns[0].DefaultConstraintName, Is.Null);
			Assert.That(op.UpdateColumns[1].DefaultExpression, Is.Null);
			Assert.That(op.UpdateColumns[1].DefaultConstraintName, Is.Null);
		}

		[Test]
		public void ShouldRemoveUpdateOperationIfTableRemoved()
		{
			var op = new UpdateTableOperation("schema", "table Name", new Column[0], new Column[0], new string[0]);
			var removeTableOp = new RemoveTableOperation("SCHEMA", "TABLE NAME");
			op.Merge(removeTableOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeTableOp.Disabled, Is.True);
		}

		[Test]
		public void ShouldNotRemoveUpdateOperationIfItIsADifferentTable()
		{
			var op = new UpdateTableOperation("schema", "tableName", new Column[0], new Column[0], new string[0]);
			var removeTableOp = new RemoveTableOperation("SCHEMA", "tableName2");
			op.Merge(removeTableOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(removeTableOp.Disabled, Is.False);
		}

		[Test]
		public void ShouldRenameAddedColumnsIfRenamed()
		{
			var columns = new Column[]
			{
				Column.Int("id", null, "description"),
				Column.VarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description")
			};
			var op = new UpdateTableOperation("schema", "table", columns, new Column[0], new string[0]);
			var renameColumnOp = new RenameColumnOperation("SCHEMA", "TABLE", "NAME", "new name");
			op.Merge(renameColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameColumnOp.Disabled, Is.True);
			Assert.That(op.AddColumns[0].Name, Is.EqualTo("id"));
			Assert.That(op.AddColumns[1].Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldRenameUpdatedColumnsIfRenamed()
		{
			var columns = new Column[]
			{
				Column.Int("id", null, "description"),
				Column.VarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description")
			};
			var op = new UpdateTableOperation("schema", "table", new Column[0], columns, new string[0]);
			var renameColumnOp = new RenameColumnOperation("SCHEMA", "TABLE", "NAME", "new name");
			op.Merge(renameColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameColumnOp.Disabled, Is.True);
			Assert.That(op.UpdateColumns[0].Name, Is.EqualTo("id"));
			Assert.That(op.UpdateColumns[1].Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldAddRowGuidColToAddedColumn()
		{
			var columns = new Column[]
			{
				Column.UniqueIdentifier("uuid", false, Nullable.Null, null, null, "description"),
				Column.UniqueIdentifier("uuid2", false, Nullable.Null, null, null, "description"),
				Column.Int("uuid", Nullable.Null, null, null, "description"),
			};
			columns[2].RowGuidCol = false;
			var op = new UpdateTableOperation("schema", "table", columns, new Column[0], new string[0]);
			var addRowGuidColOp = new AddRowGuidColOperation("SCHEMA", "TABLE", "UUID");
			op.Merge(addRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addRowGuidColOp.Disabled, Is.True);
			Assert.That(op.AddColumns[0].RowGuidCol, Is.True);
			Assert.That(op.AddColumns[1].RowGuidCol, Is.False);
			Assert.That(op.AddColumns[2].RowGuidCol, Is.False);
		}

		[Test]
		public void ShouldAddRowGuidColToUpdatedColumn()
		{
			var columns = new Column[]
			{
				Column.UniqueIdentifier("uuid", false, Nullable.Null, null, null, "description"),
				Column.UniqueIdentifier("uuid2", false, Nullable.Null, null, null, "description"),
				Column.Int("uuid", Nullable.Null, null, null, "description"),
			};
			columns[2].RowGuidCol = false;
			var op = new UpdateTableOperation("schema", "table", new Column[0], columns, new string[0]);
			var addRowGuidColOp = new AddRowGuidColOperation("SCHEMA", "TABLE", "UUID");
			op.Merge(addRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addRowGuidColOp.Disabled, Is.True);
			Assert.That(op.UpdateColumns[0].RowGuidCol, Is.True);
			Assert.That(op.UpdateColumns[1].RowGuidCol, Is.False);
			Assert.That(op.UpdateColumns[2].RowGuidCol, Is.False);
		}

		[Test]
		public void ShouldNotAddRowGuidColForAnotherTablesColumn()
		{
			var columns = new Column[]
			{
				Column.UniqueIdentifier("uuid", false, Nullable.Null, null, null, "description"),
				Column.UniqueIdentifier("uuid2", false, Nullable.Null, null, null, "description"),
				Column.Int("uuid", Nullable.Null, null, null, "description"),
			};
			var op = new UpdateTableOperation("schema", "table", new Column[0], columns, new string[0]);
			var addRowGuidColOp = new AddRowGuidColOperation("SCHEMA", "table2", "UUID");
			op.Merge(addRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addRowGuidColOp.Disabled, Is.False);
			Assert.That(op.UpdateColumns[0].RowGuidCol, Is.False);
			Assert.That(op.UpdateColumns[1].RowGuidCol, Is.False);
			Assert.That(op.UpdateColumns[2].RowGuidCol, Is.False);
		}

		[Test]
		public void ShouldRemoveAddRowGuidColToAddedColumn()
		{
			var columns = new Column[]
			{
				Column.UniqueIdentifier("uuid", true, Nullable.Null, null, null, "description"),
				Column.UniqueIdentifier("uuid2", true, Nullable.Null, null, null, "description"),
				Column.Int("uuid", Nullable.Null, null, null, "description"),
			};
			columns[2].RowGuidCol = true;
			var op = new UpdateTableOperation("schema", "table", columns, new Column[0], new string[0]);
			var removeRowGuidColOp = new RemoveRowGuidColOperation("SCHEMA", "TABLE", "UUID");
			op.Merge(removeRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(removeRowGuidColOp.Disabled, Is.True);
			Assert.That(op.AddColumns[0].RowGuidCol, Is.False);
			Assert.That(op.AddColumns[1].RowGuidCol, Is.True);
			Assert.That(op.AddColumns[2].RowGuidCol, Is.True);
		}

		[Test]
		public void ShouldRemoveRowGuidColToUpdatedColumn()
		{
			var columns = new Column[]
			{
				Column.UniqueIdentifier("uuid", true, Nullable.Null, null, null, "description"),
				Column.UniqueIdentifier("uuid2", true, Nullable.Null, null, null, "description"),
				Column.Int("uuid", Nullable.Null, null, null, "description"),
			};
			columns[2].RowGuidCol = true;
			var op = new UpdateTableOperation("schema", "table", new Column[0], columns, new string[0]);
			var removeRowGuidColOp = new RemoveRowGuidColOperation("SCHEMA", "TABLE", "UUID");
			op.Merge(removeRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(removeRowGuidColOp.Disabled, Is.True);
			Assert.That(op.UpdateColumns[0].RowGuidCol, Is.False);
			Assert.That(op.UpdateColumns[1].RowGuidCol, Is.True);
			Assert.That(op.UpdateColumns[2].RowGuidCol, Is.True);
		}

		[Test]
		public void ShouldMergeRemovedColumnsAcrossUpdateTableOperations()
		{
			var op = new UpdateTableOperation("schema", "name", null, null, new []{ "column1" });
			var removeColumnOp = new UpdateTableOperation("SCHEMA", "NAME", null, null, new [] { "column2" });
			op.Merge(removeColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(removeColumnOp.Disabled, Is.True);
			Assert.That(op.RemoveColumns.Count, Is.EqualTo(2));
			Assert.That(op.RemoveColumns[0], Is.EqualTo("column1"));
			Assert.That(op.RemoveColumns[1], Is.EqualTo("column2"));
		}

		[Test]
		public void ShouldMergeAddColumnsAcrossUpdateTableOperations()
		{
			var op = new UpdateTableOperation("schema", "name",
				new[] {Column.Int("column1", Nullable.NotNull, null, null, null)}, null, null);
			var addColumnOp = new UpdateTableOperation("SCHEMA", "NAME",
				new[] {Column.Bit("column2", Nullable.NotNull, null, null, null)}, null, null);
			op.Merge(addColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addColumnOp.Disabled, Is.True);
			Assert.That(op.AddColumns.Count, Is.EqualTo(2));
			Assert.That(op.AddColumns[0].Name, Is.EqualTo("column1"));
			Assert.That(op.AddColumns[1].Name, Is.EqualTo(addColumnOp.AddColumns[0].Name));
		}

		[Test]
		public void ShouldMergeUpdateColumnsAcrossUpdateTableOperations()
		{
			var op = new UpdateTableOperation("schema", "name", null,
				new[] { Column.Int("column1", Nullable.NotNull, null, null, null) }, null);
			var updateColumnOp = new UpdateTableOperation("SCHEMA", "NAME", null,
				new[] { Column.Bit("column2", Nullable.NotNull, null, null, null) }, null);
			op.Merge(updateColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(updateColumnOp.Disabled, Is.True);
			Assert.That(op.UpdateColumns.Count, Is.EqualTo(2));
			Assert.That(op.UpdateColumns[0].Name, Is.EqualTo("column1"));
			Assert.That(op.UpdateColumns[1].Name, Is.EqualTo(updateColumnOp.UpdateColumns[0].Name));
		}

		[Test]
		public void ShouldMergeAllColumnOperationsAcrossUpdateTableOperations()
		{
			var op = new UpdateTableOperation("schema", "name",
				new[] { Column.Int("column1", new Identity(), null), Column.Bit("column2", Nullable.Null, null, null, null) },
				new[] { Column.Int("column3", new Identity(), null), Column.Bit("column4", Nullable.Null, null, null, null) },
				new[] { "column6", "column7" });
			var otherUpdateOp = new UpdateTableOperation("SCHEMA", "NAME", 
				new [] { Column.Int("COLUMN7", Nullable.Null, null, null, null), Column.Bit("column8", Nullable.NotNull, null, null, null) },
				new [] { Column.BigInt("COLUMN1", new Identity(), null), Column.Bit("column9", Nullable.Null, null, null, null)},
				new [] { "COLUMN2", "COLUMN4", "column10" });
			op.Merge(otherUpdateOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(otherUpdateOp.Disabled, Is.True);
			Assert.That(op.AddColumns.Count, Is.EqualTo(3));
			Assert.That(op.AddColumns[0].Name, Is.EqualTo("COLUMN1"));
			Assert.That(op.AddColumns[0].DataType, Is.EqualTo(DataType.BigInt));
			Assert.That(op.AddColumns[1].Name, Is.EqualTo("COLUMN7"));
			Assert.That(op.AddColumns[2].Name, Is.EqualTo("column8"));
			Assert.That(op.UpdateColumns.Count, Is.EqualTo(2));
			Assert.That(op.UpdateColumns[0].Name, Is.EqualTo("column3"));
			Assert.That(op.UpdateColumns[1].Name, Is.EqualTo("column9"));
			Assert.That(op.RemoveColumns.Count, Is.EqualTo(2));
			Assert.That(op.RemoveColumns[0], Is.EqualTo("column6"));
			Assert.That(op.RemoveColumns[1], Is.EqualTo("column10"));
		}

		[Test]
		public void ShouldOnlyMergeOnceSoMultipleUpdateOperationsDoNotDuplicateOperations()
		{
			var op = new UpdateTableOperation("schema", "name", null, null, new[] { "column1" });
			var op2 = new UpdateTableOperation("schema", "name", null, null, new[] { "column2" });
			var op3 = new UpdateTableOperation("schema", "name", null, null, new[] { "column3" });
			var op4 = new UpdateTableOperation("schema", "name", null, null, new [] { "column4" });
			op3.Merge(op4);
			op2.Merge(op4);
			op.Merge(op4);
			op2.Merge(op3);
			op.Merge(op3);
			op.Merge(op2);
			Assert.That(op.Disabled, Is.False);
			Assert.That(op2.Disabled, Is.True);
			Assert.That(op3.Disabled, Is.True);
			Assert.That(op4.Disabled, Is.True);
			Assert.That(op.RemoveColumns.Count, Is.EqualTo(4));
			Assert.That(op.RemoveColumns[0], Is.EqualTo("column1"));
			Assert.That(op.RemoveColumns[1], Is.EqualTo("column2"));
			Assert.That(op.RemoveColumns[2], Is.EqualTo("column3"));
			Assert.That(op.RemoveColumns[3], Is.EqualTo("column4"));
		}

		[Test]
		public void ShouldMergeAllUpdatedColumns()
		{
			var op = new UpdateTableOperation("schema", "name", null, new [] { Column.Bit("bit", Nullable.NotNull, null, null, null)}, null);
			var op2 = new UpdateTableOperation("schema", "name", null, null, null);
			var op3 = new UpdateTableOperation("schema", "name", null, new[] { Column.Bit("BIT", Nullable.Null, null, null, null) }, null);

			op2.Merge(op3);
			op.Merge(op3);

			op.Merge(op2);

			Assert.That(op.Disabled, Is.False);
			Assert.That(op2.Disabled, Is.True);
			Assert.That(op3.Disabled, Is.True);

			Assert.That(op.UpdateColumns.Count, Is.EqualTo(1));
			Assert.That(op.UpdateColumns[0].Name, Is.EqualTo("BIT"));
			Assert.That(op.UpdateColumns[0].Nullable, Is.EqualTo(Nullable.Null));
		}

		[Test]
		public void ShouldDisableItselfIfAllColumnsAreRemoved()
		{
			var op = new UpdateTableOperation("schema", "name",
				new[] {Column.Int("column1", new Identity(), null)},
				new[] {Column.Int("column2", new Identity(), null)},
				null);
			var updateOp = new UpdateTableOperation("SCHEMA", "NAME", null, null, new[] {"COLUMN1", "COLUMN2"});
			op.Merge(updateOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(updateOp.Disabled, Is.True);
			Assert.That(op.AddColumns.Count, Is.Zero);
			Assert.That(op.UpdateColumns.Count, Is.Zero);
			Assert.That(op.RemoveColumns.Count, Is.Zero);

		}
	}
}