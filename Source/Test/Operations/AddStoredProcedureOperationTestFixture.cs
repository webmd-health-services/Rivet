using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddStoredProcedureOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string ProcedureName = "procedureName";
		const string Definition = "as definition";

		[Test]
		public void ShouldSetPropertiesForAddStoredProcedure()
		{
			var op = new AddStoredProcedureOperation(SchemaName, ProcedureName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ProcedureName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, ProcedureName)));
		}

		[Test]
		public void ShouldWriteQueryForAddStoredProcedure()
		{
			var op = new AddStoredProcedureOperation(SchemaName, ProcedureName, Definition);
			const string expectedQuery = "create procedure [schemaName].[procedureName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}