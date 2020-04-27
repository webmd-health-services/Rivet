using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RenameIndexOperationTestFixture
	{

		private const string SchemaName = "schemaName";
		private const string CurrentName = "currentName";
		private const string NewName = "newName";
		private const string TableName = "tableName";

		[Test]
		public void ShouldWriteQueryForRenameIndexConstraintOperation()
		{
			var op = new RenameIndexOperation(SchemaName, TableName, CurrentName, NewName);
			Assert.That(op.SchemaName, Is.EqualTo(SchemaName));
			Assert.That(op.Name, Is.EqualTo(CurrentName));
			Assert.That(op.NewName, Is.EqualTo(NewName));
			Assert.That(op.TableName, Is.EqualTo(TableName));
			Assert.That(op.ToQuery(), Contains.Substring("@objname = '[schemaName].[tableName].[currentName]', @newname = 'newName', @objtype = 'INDEX'"));
		}

		[Test]
		public void ShouldNotDisableTableRenameWhenMerging()
		{
			var renameIdx = new RenameIndexOperation("schema", "table", "name", "new name");
			var renameTable = new RenameObjectOperation("schema", "table", "new table");
			renameIdx.Merge(renameTable);
			Assert.That(renameTable.Disabled, Is.False);
			Assert.That(renameIdx.Disabled, Is.False);
		}
	}
}
