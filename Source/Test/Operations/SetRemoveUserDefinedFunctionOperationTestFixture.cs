using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class SetRemoveUserDefinedFunctionOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string ProcedureName = "procedureName";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForRemoveUserDefinedFunction()
		{
			var op = new RemoveUserDefinedFunctionOperation(SchemaName, ProcedureName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ProcedureName, op.ProcedureName);
		}

		[Test]
		public void ShouldWriteQueryForRemoveUserDefinedFunction()
		{
			var op = new RemoveUserDefinedFunctionOperation(SchemaName, ProcedureName);
			const string expectedQuery = "drop function [schemaName].[procedureName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}