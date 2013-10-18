using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateViewTestFixture
	{
		const string SchemaName = "schemaName";
		const string ViewName = "viewName";
		const string Definition = "as definition";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForUpdateViewOperation()
		{
			var op = new UpdateViewOperation(SchemaName, ViewName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ViewName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
		}

		[Test]
		public void ShouldWriteQueryForAddViewOperation()
		{
			var op = new UpdateViewOperation(SchemaName, ViewName, Definition);
			const string expectedQuery = "alter view [schemaName].[viewName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}