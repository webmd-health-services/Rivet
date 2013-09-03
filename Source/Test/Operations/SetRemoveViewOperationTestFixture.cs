using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class SetRemoveViewOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string ProcedureName = "procedureName";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForRemoveStoredProcedure()
		{
			var op = new RemoveViewOperation(SchemaName, ProcedureName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ProcedureName, op.ProcedureName);
		}

		[Test]
		public void ShouldWriteQueryForRemoveStoredProcedure()
		{
			var op = new RemoveViewOperation(SchemaName, ProcedureName);
			const string expectedQuery = "drop view [schemaName].[procedureName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}