using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateUserDefinedFunctionTestFixture
	{
		const string SchemaName = "schemaName";
		const string FunctionName = "functionName";
		const string Definition = "as definition";

		[Test]
		public void ShouldSetPropertiesForUpdateUserDefinedFunction()
		{
			var op = new UpdateUserDefinedFunctionOperation(SchemaName, FunctionName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(FunctionName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, FunctionName)));
		}

		[Test]
		public void ShouldWriteQueryForAddUserDefinedFunction()
		{
			var op = new UpdateUserDefinedFunctionOperation(SchemaName, FunctionName, Definition);
			const string expectedQuery = "alter function [schemaName].[functionName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}