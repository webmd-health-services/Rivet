using System.Diagnostics;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveCheckConstraintOperationTestFixture
	{
		
		[Test]
		public void ShouldSetPropertiesForRemoveCheckConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var constraintName = "constraintName";

			var op = new RemoveCheckConstraintOperation(schemaName, tableName, constraintName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(constraintName, op.Name);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}.{2}", schemaName, tableName, constraintName)));
		}

		[Test]
		public void ShouldWriteQueryForRemoveCheckConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var constraintName = "constraintName";

			var op = new RemoveCheckConstraintOperation(schemaName, tableName, constraintName);
			Trace.WriteLine(op.ToQuery());
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [constraintName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
		

	}

}
