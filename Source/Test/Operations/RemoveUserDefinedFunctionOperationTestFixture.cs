using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveUserDefinedFunctionOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string FunctionName = "functionName";

		[Test]
		public void ShouldSetPropertiesForRemoveUserDefinedFunction()
		{
			var op = new RemoveUserDefinedFunctionOperation(SchemaName, FunctionName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(FunctionName, op.Name);
		}

		[Test]
		public void ShouldWriteQueryForRemoveUserDefinedFunction()
		{
			var op = new RemoveUserDefinedFunctionOperation(SchemaName, FunctionName);
			const string expectedQuery = "drop function [schemaName].[functionName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}