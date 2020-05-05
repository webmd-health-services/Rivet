using System;
using System.Linq;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddForeignKeyConstraintTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForAddForeignKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var name = "name";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			string[] referencesColumnName = new string[] { "rcolumn1", "rcolumn2" };
			string[] smokeReferencesColumnName = new string[] { "rcolumn1" };
			var referencesSchemaName = "rschemaName";
			var referencesTableName = "rtableName";
			var onDelete = "onDelete";
			var onUpdate = "onUpdate";
			bool notForReplication = true;

			var op = new AddForeignKeyOperation(schemaName, tableName, name, columnName, referencesSchemaName, referencesTableName, referencesColumnName, onDelete, onUpdate, notForReplication, false);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(referencesColumnName, op.ReferencesColumnName);
			Assert.AreNotEqual(smokeReferencesColumnName, op.ReferencesColumnName);
			Assert.AreEqual(referencesSchemaName, op.ReferencesSchemaName);
			Assert.AreEqual(referencesTableName, op.ReferencesTableName);
			Assert.AreEqual(name, op.Name.ToString());
			Assert.AreEqual(onDelete, op.OnDelete);
			Assert.AreEqual(onUpdate, op.OnUpdate);
			Assert.AreEqual(notForReplication, op.NotForReplication);
		}

		[Test]
		public void ShouldWriteQueryForAddForeignKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] referencesColumnName = new string[] { "rcolumn1", "rcolumn2" };
			var referencesSchemaName = "rschemaName";
			var referencesTableName = "rtableName";
			var name = "name";
			var onDelete = "onDelete";
			var onUpdate = "onUpdate";
			bool notForReplication = true;

			var op = new AddForeignKeyOperation(schemaName, tableName, name, columnName, referencesSchemaName, referencesTableName, referencesColumnName, onDelete, onUpdate, notForReplication, false);
			var expectedQuery = $"alter table [{schemaName}].[{tableName}] add constraint [{name}] foreign key ([{string.Join("],[", columnName)}]) " +
									  $"references [{referencesSchemaName}].[{referencesTableName}] ([{string.Join("],[", referencesColumnName)}]) " +
									  $"on delete {onDelete} on update {onUpdate} not for replication";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			var op = new AddForeignKeyOperation("schema", "table","name", new[] { "column" }, "referencesSchema", "referencesTable", new[] { "column" }, "OK", "OK", false, false);
			op.Name = "new name";
			Assert.That(op.Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveOperation()
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new string[0], "ref_schema", "ref_table", new string[0], "delete", "update", false, false);
			var removeOp = new RemoveForeignKeyOperation("SCHEMA", "TABLE", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}

		[Test]
		public void ShouldRenameSourceColumnIfRenamed()
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new[] { "column", "column2" }, "ref schema", "ref table", new string[] { "ref column", "ref column2" }, "on delete", "on update", false, false);

			var renameColumnOp = new RenameColumnOperation("SCHEMA", "TABLE", "COLUMN", "new column");
			op.Merge(renameColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameColumnOp.Disabled, Is.True);
			Assert.That(op.ColumnName[0], Is.EqualTo("new column"));
			Assert.That(op.ColumnName[1], Is.EqualTo("column2"));
			Assert.That(op.ReferencesColumnName[0], Is.EqualTo("ref column"));
			Assert.That(op.ReferencesColumnName[1], Is.EqualTo("ref column2"));

		}

		[Test]
		public void ShouldRenameReferenceColumnIfRenamed()
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new[] { "column", "column2" }, "ref schema", "ref table", new string[] { "ref column", "ref column2" }, "on delete", "on update", false, false);

			var renameColumnOp = new RenameColumnOperation("REF SCHEMA", "REF TABLE", "REF COLUMN", "new column");
			op.Merge(renameColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameColumnOp.Disabled, Is.True);
			Assert.That(op.ColumnName[0], Is.EqualTo("column"));
			Assert.That(op.ColumnName[1], Is.EqualTo("column2"));
			Assert.That(op.ReferencesColumnName[0], Is.EqualTo("new column"));
			Assert.That(op.ReferencesColumnName[1], Is.EqualTo("ref column2"));
		}

		[Test]
		[TestCase("other schema", "table")]
		[TestCase("schema", "other table")]
		public void ShouldNotRenameReferenceColumnIfReferencesDifferentTableThatIsRenamed(string schemaName, string tableName)
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new[] { "column", "column2" }, "ref schema", "ref table", new string[] { "ref column", "ref column2" }, "on delete", "on update", false, false);

			var renameColumnOp = new RenameColumnOperation(schemaName, tableName, "REF COLUMN", "new column");
			op.Merge(renameColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameColumnOp.Disabled, Is.False);
			Assert.That(op.ColumnName[0], Is.EqualTo("column"));
			Assert.That(op.ColumnName[1], Is.EqualTo("column2"));
			Assert.That(op.ReferencesColumnName[0], Is.EqualTo("ref column"));
			Assert.That(op.ReferencesColumnName[1], Is.EqualTo("ref column2"));
		}

		[Test]
		public void ShouldChangeConstraintTableNameIfTableRenamed()
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new string[0], "ref schema", "ref table", new string[0], "on delete", "on update", false, false);
			var renameTableOp = new RenameObjectOperation("SCHEMA", "TABLE", "new table");
			op.Merge(renameTableOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameTableOp.Disabled, Is.True);
			Assert.That(op.TableName, Is.EqualTo(renameTableOp.NewName));
		}

		[Test]
		public void ShouldChangeConstraintReferencedTableNameIfReferencedTableRenamed()
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new string[0], "ref schema", "ref table", new string[0], "on delete", "on update", false, false);
			var renameTableOp = new RenameObjectOperation("REF SCHEMA", "REF TABLE", "new table");
			op.Merge(renameTableOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameTableOp.Disabled, Is.True);
			Assert.That(op.ReferencesTableName, Is.EqualTo(renameTableOp.NewName));
		}

		[Test]
		[TestCase("other schema", "table")]
		[TestCase("schema", "other table")]
		public void ShouldNotChangeConstraintReferencedTableNameIfANonReferencedTableRenamed(string schemaName, string tableName)
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new string[0], "ref schema", "ref table", new string[0], "on delete", "on update", false, false);
			var renameTableOp = new RenameObjectOperation(schemaName, tableName, "new table");
			op.Merge(renameTableOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameTableOp.Disabled, Is.False);
			Assert.That(op.ReferencesTableName, Is.EqualTo("ref table"));
		}

		[Test]
		public void ShouldChangeConstraintName()
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new string[0], "ref schema", "ref table",
				new string[0], "on delete", "on update", false, false);
			var renameOp = new RenameObjectOperation("SCHEMA", "NAME", "new name");
			op.Merge(renameOp);
			Assert.That(op.Name, Is.EqualTo("new name"));
			Assert.That(renameOp.Disabled);
			Assert.That(op.Disabled, Is.False);
		}

		[Test]
		public void ShouldNotDisableAddIfRemovingAForeignKeyOnTheSameTable()
		{
			var op = new AddForeignKeyOperation("schema", "table", "name", new string[0], "ref schema", "ref table",
				new string[0], "on delete", "on update", false, false);
			var removeOp = new RemoveForeignKeyOperation("schema", "table", "name2");

			op.Merge(removeOp);

			Assert.That(removeOp.Disabled, Is.False);
			Assert.That(op.Disabled, Is.False);
		}
	}
}