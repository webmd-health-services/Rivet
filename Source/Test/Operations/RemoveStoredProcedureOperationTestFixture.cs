using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveStoredProcedureOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string ProcedureName = "procedureName";

		[Test]
		public void ShouldSetPropertiesForRemoveStoredProcedure()
		{
			var op = new RemoveStoredProcedureOperation(SchemaName, ProcedureName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ProcedureName, op.Name);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, ProcedureName)));
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