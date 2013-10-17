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
		private UpdateRowOperation op;

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
			GivenRows(Where);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(SanDiego, op.Column);
			Assert.AreEqual(Where, op.Where);
			Assert.IsFalse(op.All);
		}

		[Test]
		public void ShouldSetPropertiesForUpdateAllRows()
		{
			GivenRows();
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(SanDiego, op.Column);
			Assert.IsTrue(op.All);
		}

		[Test]
		public void ShouldWriteQueryForUpdateSpecificRows()
		{
			GivenRows("City = 'San Diego'");
			ThenQueryIs("update [schemaName].[tableName] set Population = 1234567, State = 'Oregon' where City = 'San Diego'");
		}

		[Test]
		public void ShouldWriteQueryForUpdateAllRows()
		{
			GivenRows();
			ThenQueryIs("update [schemaName].[tableName] set Population = 1234567, State = 'Oregon'");
		}

		[Test]
		public void ShouldNotEscapeColumns()
		{
			GivenRawRows();
			ThenQueryIs("update [schemaName].[tableName] set Population = 1234567, State = Oregon");
		}

		private void GivenRows()
		{
			op = new UpdateRowOperation(SchemaName, TableName, SanDiego, false);
		}

		private void GivenRows(string where)
		{
			op = new UpdateRowOperation(SchemaName, TableName, SanDiego, where, false);
		}

		private void GivenRawRows()
		{
			op = new UpdateRowOperation(SchemaName, TableName, SanDiego, true);
		}

		private void ThenQueryIs(string query)
		{
			Assert.AreEqual(query, op.ToQuery());
		}

	}
}