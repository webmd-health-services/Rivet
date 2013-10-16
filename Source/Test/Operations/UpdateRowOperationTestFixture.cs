using NUnit.Framework;
using Rivet.Operations;
using System.Collections;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateRowOperationTestFixture
	{
		private const string SchemaName = "schemaName";
		private const string TableName = "tableName";
		private const string Where = "City = 'San Diego'";

		private static readonly Hashtable SanDiego = new Hashtable
		{
			{"State", "Oregon"},
			{"Population", 1234567}
		};

		[SetUp]
		public void SetUp()
		{
		}

		[Test]
		public void ShouldSetPropertiesForUpdateSpecificRows()
		{
			var op = new UpdateRowOperation(SchemaName, TableName, SanDiego, Where);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(SanDiego, op.Column);
			Assert.AreEqual(Where, op.Where);
			Assert.IsFalse(op.All);
		}

		[Test]
		public void ShouldSetPropertiesForUpdateAllRows()
		{
			var op = new UpdateRowOperation(SchemaName, TableName, SanDiego);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(SanDiego, op.Column);
			Assert.IsTrue(op.All);
		}

		[Test]
		public void ShouldWriteQueryForUpdateSpecificRows()
		{
			var op = new UpdateRowOperation(SchemaName, TableName, SanDiego, Where);
			const string expectedQuery = "update [schemaName].[tableName] set Population = 1234567, State = 'Oregon' where City = 'San Diego';";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForUpdateAllRows()
		{
			var op = new UpdateRowOperation(SchemaName, TableName, SanDiego);
			const string expectedQuery = "update [schemaName].[tableName] set Population = 1234567, State = 'Oregon';";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}