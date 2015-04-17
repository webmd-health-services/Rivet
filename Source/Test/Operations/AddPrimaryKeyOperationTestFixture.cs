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
			string [] columnName = new string[] { "column1", "column2" };
			string[] smokeColumn = new string[] { "column1" };
			bool nonClustered = true;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeoptions = new string[] { "option1" };

			var op = new AddPrimaryKeyOperation(schemaName, tableName, columnName, nonClustered, options);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumn, op.ColumnName);
			Assert.AreEqual(nonClustered, op.NonClustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeoptions, op.Options);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}.PK_{0}_{1}", schemaName, tableName)));
		}

		[Test]
		public void ShouldSetPropertiesForAddPrimaryKeyWithCustomConstraintName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumn = new string[] { "column1" };
			var customConstraintName = "customConstraintName";
			bool nonClustered = true;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeoptions = new string[] { "option1" };

			var op = new AddPrimaryKeyOperation(schemaName, tableName, columnName, customConstraintName, nonClustered, options);
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
			bool nonClustered = true;
			string[] options = new string[] { "option1", "option2" };

			var op = new AddPrimaryKeyOperation(schemaName, tableName, columnName, nonClustered, options);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [PK_schemaName_tableName] primary key nonclustered ([column1], [column2]) with ( option1, option2 )";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddPrimaryKeyWithCustomName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			var customConstraintName = "customConstraintName";
			bool nonClustered = true;
			string[] options = new string[] { "option1", "option2" };

			var op = new AddPrimaryKeyOperation(schemaName, tableName, columnName, customConstraintName, nonClustered, options);
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

			var op = new AddPrimaryKeyOperation(schemaName, tableName, columnName, nonClustered, null);
			var expectedQuery = "alter table [dbo].[tableName] add constraint [PK_tableName] primary key clustered ([column1])";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}
