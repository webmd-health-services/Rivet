using System.Diagnostics;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveSynonymOperationTestFixture
	{
		private const string SchemaName = "schemaName";
		private const string Name = "name";

		[Test]
		public void ShouldWriteQueryForRemoveSynonym()
		{
			var op = new RemoveSynonymOperation(SchemaName, Name);
			Trace.WriteLine(op.ToQuery());
			const string expectedQuery = "drop synonym [schemaName].[name]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, Name)));
		}

	}
}