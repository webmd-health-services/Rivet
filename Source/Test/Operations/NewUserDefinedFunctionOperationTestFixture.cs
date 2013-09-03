using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class NewUserDefinedFunctionTestFixture
	{
		const string SchemaName = "schemaName";
		const string FunctionName = "functionName";
		const string Definition = "as definition";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForNewStoredProcedure()
		{
			var op = new NewUserDefinedFunctionOperation(SchemaName, FunctionName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(FunctionName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
		}

		[Test]
		public void ShouldWriteQueryForNewStoredProcedure()
		{
			var op = new NewUserDefinedFunctionOperation(SchemaName, FunctionName, Definition);
			const string expectedQuery = "create function [schemaName].[functionName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}