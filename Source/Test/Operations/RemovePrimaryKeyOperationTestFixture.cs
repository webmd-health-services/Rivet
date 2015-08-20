using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemovePrimaryKeyOperationTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForRemovePrimaryKey()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string name = "primary key";

			var removePrimaryKeyOperation = new RemovePrimaryKeyOperation(schemaName, tableName, name);
			var op = removePrimaryKeyOperation;
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}.{2}", schemaName, tableName, name)));
			Assert.That(op.Name, Is.EqualTo(name));
			var expectedQuery = string.Format("alter table [{0}].[{1}] drop constraint [{2}]", schemaName, tableName, name);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}
