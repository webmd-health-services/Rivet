using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveColumnOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{
		}

		[Test]
		public void ShouldSetPropertiesforColumn()
		{
			var tableName = "tableName";
			var schemaName = "schemaName";
			var columnName = "columnName";

			var op = new RemoveColumnOperation(schemaName, tableName, columnName);
			Assert.That(op.TableName, Is.EqualTo(tableName));
			Assert.That(op.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op.Name, Is.SameAs(columnName));

			var expectedQuery = string.Format("alter table [{0}].[{1}] drop column [{2}]", schemaName, tableName, columnName);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

		}
	}
}
