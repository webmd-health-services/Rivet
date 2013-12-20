using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveTableOperationTestFixture
	{

		[Test]
		public void ShouldSetPropertiesForRemoveTable()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";

			var op = new RemoveTableOperation(schemaName, tableName);

			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.Name);
		}

		[Test]
		public void ShouldWriteQueryForRemoveTable()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";

			var op = new RemoveTableOperation(schemaName, tableName);
			var expectedQuery = string.Format("drop table [{0}].[{1}]", schemaName, tableName);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}
	}
}
