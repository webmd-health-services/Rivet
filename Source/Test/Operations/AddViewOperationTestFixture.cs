using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddViewTestFixture
	{
		const string SchemaName = "schemaName";
		const string ViewName = "viewName";
		const string Definition = "as definition";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForAddViewOperation()
		{
			var op = new AddViewOperation(SchemaName, ViewName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ViewName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
		}

		[Test]
		public void ShouldWriteQueryForAddViewOperation()
		{
			var op = new AddViewOperation(SchemaName, ViewName, Definition);
			const string expectedQuery = "create view [schemaName].[viewName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}