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

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForRenameOperation()
		{
			var op = new RenameOperation(SchemaName, CurrentName, NewName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(CurrentName, op.CurrentName);
			Assert.AreEqual(NewName, op.NewName);
		}

		[Test]
		public void ShouldWriteQueryForAddViewOperation()
		{
			var op = new RenameOperation(SchemaName, CurrentName, NewName);
			const string expectedQuery = "declare @valback int; exec @valback = sp_rename 'schemaName.currentName', 'newName'; select @valback;";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}