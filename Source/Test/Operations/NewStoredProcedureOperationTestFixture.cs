using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class NewStoredProcedureOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string ProcedureName = "procedureName";
		const string Definition = "as definition";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForNewStoredProcedure()
		{
			var op = new NewStoredProcedureOperation(SchemaName, ProcedureName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ProcedureName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
		}

		[Test]
		public void ShouldWriteQueryForNewStoredProcedure()
		{
			var op = new NewStoredProcedureOperation(SchemaName, ProcedureName, Definition);
			const string expectedQuery = "create procedure [schemaName].[procedureName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}