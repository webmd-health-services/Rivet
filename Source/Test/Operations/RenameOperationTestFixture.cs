using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RenameOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string TableName = "tableName";
		const string CurrentName = "currentName";
		const string NewName = "newName";
		private ConstraintType index = ConstraintType.Index;
		private ConstraintType foreign = ConstraintType.ForeignKey;

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForRenameTableOperation()
		{
			var op = new RenameOperation(SchemaName, CurrentName, NewName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(CurrentName, op.CurrentName);
			Assert.AreEqual(NewName, op.NewName);
		}

		[Test]
		public void ShouldSetPropertiesForRenameColumnOperation()
		{
			var op = new RenameOperation(SchemaName, TableName, CurrentName, NewName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(CurrentName, op.CurrentName);
			Assert.AreEqual(NewName, op.NewName);
		}

		[Test]
		public void ShouldSetPropertiesForRenameConstraintOperation()
		{
			var op = new RenameOperation(SchemaName, TableName, CurrentName, NewName, foreign);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableName);
			Assert.AreEqual(CurrentName, op.CurrentName);
			Assert.AreEqual(NewName, op.NewName);
			Assert.AreEqual(foreign, op.ConstraintType);
		}


		[Test]
		public void ShouldWriteQueryForRenameTableOperation()
		{
			var op = new RenameOperation(SchemaName, CurrentName, NewName);
			const string expectedQuery = "declare @valback int; exec @valback = sp_rename 'schemaName.currentName', 'newName'; select @valback;";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRenameColumnOperation()
		{
			var op = new RenameOperation(SchemaName, TableName, CurrentName, NewName);
			const string expectedQuery = "declare @valback int; exec @valback = sp_rename 'schemaName.tableName.currentName', 'newName', 'COLUMN'; select @valback;";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRenameConstraintOperation()
		{
			var op = new RenameOperation(SchemaName, TableName, CurrentName, NewName, foreign);
			const string expectedQuery = "declare @valback int; exec @valback = sp_rename 'schemaName.currentName', 'newName'; select @valback;";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRenameIndexConstraintOperation()
		{
			var op = new RenameOperation(SchemaName, TableName, CurrentName, NewName, index);
			const string expectedQuery = "declare @valback int; exec @valback = sp_rename 'schemaName.tableName.currentName', 'newName', 'INDEX'; select @valback;";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}