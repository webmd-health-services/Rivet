using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemovePrimaryKeyOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForRemovePrimaryKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";

			var op = new RemovePrimaryKeyOperation(schemaName, tableName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
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
			Assert.AreEqual(customConstraintName, op.Name.ToString());
		}

		[Test]
		public void ShouldWriteQueryForRemovePrimaryKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";

			var op = new RemovePrimaryKeyOperation(schemaName, tableName);
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
