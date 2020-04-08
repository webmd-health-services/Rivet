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
	    private const string TypeName = "OBJECT";

		[Test]
		public void ShouldSetPropertiesForRenameTableOperation()
		{
			var op = new RenameObjectOperation(SchemaName, CurrentName, NewName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(CurrentName, op.Name);
			Assert.AreEqual(NewName, op.NewName);
            Assert.AreEqual(TypeName, op.Type);
		}

		[Test]
		public void ShouldWriteQueryForRenameTableOperation()
		{
			var op = new RenameObjectOperation(SchemaName, CurrentName, NewName);
			Assert.That(op.ToQuery(), Contains.Substring("@objname = '[schemaName].[currentName]', @newname = 'newName', @objtype = 'OBJECT'"));
		}
	}
}