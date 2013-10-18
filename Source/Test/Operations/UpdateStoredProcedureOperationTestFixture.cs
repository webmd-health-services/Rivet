using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateStoredProcedureOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string ProcedureName = "procedureName";
		const string Definition = "as definition";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForUpdateStoredProcedure()
		{
			var op = new UpdateStoredProcedureOperation(SchemaName, ProcedureName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ProcedureName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
		}

		[Test]
		public void ShouldWriteQueryForUpdateStoredProcedure()
		{
			var op = new UpdateStoredProcedureOperation(SchemaName, ProcedureName, Definition);
			const string expectedQuery = "alter procedure [schemaName].[procedureName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}