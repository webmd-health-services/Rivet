using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddPrimaryKeyOperationTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForAddPrimaryKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumn = new string[] { "column1" };
			var customConstraintName = "customConstraintName";
			bool nonClustered = true;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeoptions = new string[] { "option1" };

			var op = new AddPrimaryKeyOperation(schemaName, tableName, customConstraintName, columnName, nonClustered, options);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumn, op.ColumnName);
			Assert.AreEqual(customConstraintName, op.Name.ToString());
			Assert.AreEqual(nonClustered, op.NonClustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeoptions, op.Options);
		}

		[Test]
		public void ShouldWriteQueryForAddPrimaryKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			var customConstraintName = "customConstraintName";
			bool nonClustered = true;
			string[] options = new string[] { "option1", "option2" };

			var op = new AddPrimaryKeyOperation(schemaName, tableName, customConstraintName, columnName, nonClustered, options);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [customConstraintName] primary key nonclustered ([column1], [column2]) with ( option1, option2 )";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithDifferentSettingsForAddPrimaryKey()
		{
			var schemaName = "dbo";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1" };
			bool nonClustered = false;

			var op = new AddPrimaryKeyOperation(schemaName, tableName, "name", columnName, nonClustered, null);
			var expectedQuery = "alter table [dbo].[tableName] add constraint [name] primary key clustered ([column1])";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			var op = new AddPrimaryKeyOperation("schema", "table", "name", new[] {"column"}, false, null);
			op.Name = "new name";
			Assert.That(op.Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveOperation()
		{
			var op = new AddPrimaryKeyOperation("schema", "table", "name", new string[0], false, new string[0]);
			var removeOp = new RemovePrimaryKeyOperation("SCHEMA", "TABLE", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}
	}
}
