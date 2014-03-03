using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RenameColumnOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string TableName = "tableName";
		const string CurrentName = "currentName";
		const string NewName = "newName";

		[Test]
		public void ShouldSetPropertiesForRenameColumnOperation()
		{
			var op = new RenameColumnOperation(SchemaName, TableName, CurrentName, NewName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(CurrentName, op.Name);
			Assert.AreEqual(NewName, op.NewName);
		}

		[Test]
		public void ShouldWriteQueryForRenameColumnOperation()
		{
			var op = new RenameColumnOperation(SchemaName, TableName, CurrentName, NewName);
			Assert.That(op.ToQuery(), Contains.Substring("@objname = 'schemaName.tableName.currentName', @newname = 'newName', @objtype = 'COLUMN'"));
		}

	}
}
