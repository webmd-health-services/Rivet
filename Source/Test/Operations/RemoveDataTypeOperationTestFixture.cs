using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveDataTypeOperationTestFixture
	{

		private const string SchemaName = "schemaName";
		private const string Name = "name";

		[Test]
		public void ShouldSetPropertiesForRemoveDataTypeAlias()
		{
			var op = new RemoveDataTypeOperation(SchemaName, Name);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, Name)));
		}

		[Test]
		public void ShouldWriteQueryForRemoveDataTypeAlias()
		{
			var op = new RemoveDataTypeOperation(SchemaName, Name);
			var expectedQuery = "drop type [schemaName].[name]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}

}
