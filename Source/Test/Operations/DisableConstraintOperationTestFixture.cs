using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class DisableConstraintOperationTestFixture
	{
		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			const string schemaName = "schema";
			const string tableName = "table";
			const string name = "name";

			var op = new DisableConstraintOperation(schemaName, tableName, name);
			Assert.That(op.Name, Is.EqualTo(name));
			Assert.That(op.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op.TableName, Is.EqualTo(tableName));
			Assert.That(op.ToQuery(),
				Is.EqualTo(string.Format("alter table [{0}].[{1}] nocheck constraint [{2}]", schemaName, tableName, name)));
		}
	}

}