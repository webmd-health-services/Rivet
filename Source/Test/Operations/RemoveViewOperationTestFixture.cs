using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveViewOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string ViewName = "viewName";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForRemoveViewOperation()
		{
			var op = new RemoveViewOperation(SchemaName, ViewName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ViewName, op.ViewName);
		}

		[Test]
		public void ShouldWriteQueryForRemoveViewOperation()
		{
			var op = new RemoveViewOperation(SchemaName, ViewName);
			const string expectedQuery = "drop view [schemaName].[viewName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}