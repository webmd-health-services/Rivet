using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RenameOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string CurrentName = "currentName";
		const string NewName = "newName";

		[Test]
		public void ShouldSetPropertiesForRenameTableOperation()
		{
			var op = new RenameOperation(SchemaName, CurrentName, NewName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(CurrentName, op.Name);
			Assert.AreEqual(NewName, op.NewName);
		}

		[Test]
		public void ShouldWriteQueryForRenameTableOperation()
		{
			var op = new RenameOperation(SchemaName, CurrentName, NewName);
			Assert.That(op.ToQuery(), Contains.Substring("'schemaName.currentName', 'newName', 'OBJECT'"));
		}
	}
}