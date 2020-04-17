using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveIndexOperationTestFixture
	{

		[Test]
		public void ShouldSetPropertiesForRemoveIndex()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string name = "name";


			var op = new RemoveIndexOperation(schemaName, tableName, name, new[] { "column" }, true);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.Name, Is.EqualTo(name));
			var expectedQuery = string.Format("drop index [{0}] on [{1}].[{2}]", name, schemaName, tableName);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}
