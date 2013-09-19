using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveRowOperationTestFixture
	{
		private const string SchemaName = "schemaName";
		private const string TableName = "tableName";
		private const string Where = "(sample meaningless where string)";

		[SetUp]
		public void SetUp()
		{
		}

		[Test]
		public void ShouldSetPropertiesForRemoveSpecificRows()
		{
			var op = new RemoveRowOperation(SchemaName, TableName, Where);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(Where, op.Where);
			Assert.IsFalse(op.All);
		}

		[Test]
		public void ShouldSetPropertiesForRemoveAllRows()
		{
			var op = new RemoveRowOperation(SchemaName, TableName, true);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(true, op.Truncate);
			Assert.IsTrue(op.All);
		}

		[Test]
		public void ShouldWriteQueryForRemoveSpecificRows()
		{
			var op = new RemoveRowOperation(SchemaName, TableName, Where);
			const string expectedQuery = "delete from [schemaName].[tableName] where (sample meaningless where string);";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRemoveAllRows()
		{
			var op = new RemoveRowOperation(SchemaName, TableName, false);
			const string expectedQuery = "delete from [schemaName].[tableName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
			Assert.IsFalse(op.TruncateStatus());
		}

		[Test]
		public void ShouldWriteQueryForRemoveAllRowsWithTruncate()
		{
			var op = new RemoveRowOperation(SchemaName, TableName, true);
			const string expectedQuery = "truncate table  [schemaName].[tableName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
			Assert.IsTrue(op.TruncateStatus());
		}
	}
}