using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveDefaultConstraintOperationTestFixture
	{

		[Test]
		public void ShouldSetPropertiesForRemoveDefaultConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var name = "columnName";

			var op = new RemoveDefaultConstraintOperation(schemaName, tableName, name);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.Name, Is.EqualTo(name));
		}

		[Test]
		public void ShouldWriteQueryForRemoveDefaultConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var constraintName = "columnName";

			var op = new RemoveDefaultConstraintOperation(schemaName, tableName, constraintName);
			var expectedQuery = string.Format("alter table [{0}].[{1}] drop constraint [{2}]", schemaName, tableName, constraintName);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}

}
