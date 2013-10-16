using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveStoredProcedureOperationTestFixture
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
			var op = new RemoveStoredProcedureOperation(SchemaName, ProcedureName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ProcedureName, op.ProcedureName);
		}

		[Test]
		public void ShouldWriteQueryForRemoveStoredProcedure()
		{
			var op = new RemoveStoredProcedureOperation(SchemaName, ProcedureName);
			const string expectedQuery = "drop procedure [schemaName].[procedureName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
 
	}
}