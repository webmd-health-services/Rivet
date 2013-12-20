using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveUniqueKeyTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForRemoveUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };

			var op = new RemoveUniqueKeyOperation(schemaName, tableName, columnName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
		}

		[Test]
		public void ShouldSetPropertiesForRemoveUniqueConstraintWithCustomName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var customConstraintName = "customConstraintName";

			var op = new RemoveUniqueKeyOperation(schemaName, tableName, customConstraintName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.ColumnName, Is.Null);
			Assert.AreEqual(customConstraintName, op.Name.ToString());
		}

		[Test]
		public void ShouldWriteQueryForRemoveUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };

			var op = new RemoveUniqueKeyOperation(schemaName, tableName, columnName);
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [AK_schemaName_tableName_column1_column2]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRemoveUniqueConstraintWithCustomName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var customConstraintName = "customConstraintName";

			var op = new RemoveUniqueKeyOperation(schemaName, tableName, customConstraintName);
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [customConstraintName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}

}