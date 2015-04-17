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

		[Test]
		public void ShouldSetPropertiesForAddViewOperation()
		{
			var op = new AddViewOperation(SchemaName, ViewName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ViewName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, ViewName)));
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