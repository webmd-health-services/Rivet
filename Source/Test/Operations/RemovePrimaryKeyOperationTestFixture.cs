using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemovePrimaryKeyOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{

		}

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

		[Test]
		public void ShouldSetPropertiesForRemovePrimaryKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumn = new string[] { "column1" };

			var op = new RemovePrimaryKeyOperation(schemaName, tableName, columnName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumn, op.ColumnName);
		}

		[Test]
		public void ShouldSetPropertiesForRemovePrimaryKeyWithCustomName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var customConstraintName = "customConstraintName";

			var op = new RemovePrimaryKeyOperation(schemaName, tableName, customConstraintName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.ColumnName, Is.Null);
			Assert.AreEqual(customConstraintName, op.Name.ToString());
		}

		[Test]
		public void ShouldWriteQueryForRemovePrimaryKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };

			var op = new RemovePrimaryKeyOperation(schemaName, tableName, columnName);
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [PK_schemaName_tableName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRemovePrimaryKeyWithCustomConstraintName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var customConstraintName = "customConstraintName";

			var op = new RemovePrimaryKeyOperation(schemaName, tableName, customConstraintName);
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [customConstraintName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}
