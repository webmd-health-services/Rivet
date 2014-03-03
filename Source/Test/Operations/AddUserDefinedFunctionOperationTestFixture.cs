using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddUserDefinedFunctionTestFixture
	{
		const string SchemaName = "schemaName";
		const string FunctionName = "functionName";
		const string Definition = "as definition";

		[Test]
		public void ShouldSetPropertiesForAddUserDefinedFunction()
		{
			var op = new AddUserDefinedFunctionOperation(SchemaName, FunctionName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(FunctionName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, FunctionName)));
		}

		[Test]
		public void ShouldWriteQueryForAddUserDefinedFunction()
		{
			var op = new AddUserDefinedFunctionOperation(SchemaName, FunctionName, Definition);
			const string expectedQuery = "create function [schemaName].[functionName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}