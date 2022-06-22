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
			Assert.That(op.ToQuery(), Contains.Substring("@objname = '[schemaName].[tableName].[currentName]', @newname = 'newName', @objtype = 'COLUMN'"));
		}

		[Test]
		public void ShouldNotRenameTableIfTableIsRenamedAfterColumnsAreRenamed()
		{
			var columns = new[]
			{
				Column.Int("c1", Nullable.NotNull, null, null, "description"),
				Column.VarChar("c2", new CharacterLength(1008), "collation", Nullable.NotNull, null, null, "description")
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "textimagefilegroup", "filestreamfilegroup", new string[0]);
			var renameColumn1Op = new RenameColumnOperation("SCHEMA", "TABLE", "C1", "C1New");
			var renameColumn2Op = new RenameColumnOperation("SCHEMA", "TABLE", "C2", "C2New");
			var renameTableOp = new RenameObjectOperation("SCHEMA", "TABLE", "T1New");

			renameColumn2Op.Merge(renameTableOp);
			renameColumn1Op.Merge(renameTableOp);
			op.Merge(renameTableOp);

			renameColumn1Op.Merge(renameColumn2Op);
			op.Merge(renameColumn2Op);

			op.Merge(renameColumn1Op);

			Assert.That(op.Disabled, Is.False);
			Assert.That(renameColumn1Op.Disabled, Is.True);
			Assert.That(renameColumn2Op.Disabled, Is.True);
			Assert.That(renameTableOp.Disabled, Is.True);
			Assert.That(columns[0].Name, Is.EqualTo("C1New"));
			Assert.That(columns[1].Name, Is.EqualTo("C2New"));
			Assert.That(renameColumn2Op.TableName, Is.EqualTo("T1New"));
			Assert.That(renameColumn1Op.TableName, Is.EqualTo("T1New"));
			Assert.That(op.Name, Is.EqualTo("T1New"));
		}

		[Test]
		public void ShouldNotRenameTableIfRenamedTableNotAddedDuringMerge()
		{
			var renameColumn1Op = new RenameColumnOperation("SCHEMA", "TABLE", "C1", "C1New");
			var renameColumn2Op = new RenameColumnOperation("SCHEMA", "TABLE", "C2", "C2New");
			var renameTableOp = new RenameObjectOperation("SCHEMA", "TABLE", "T1New");

			renameColumn2Op.Merge(renameTableOp);
			renameColumn1Op.Merge(renameTableOp);

			renameColumn1Op.Merge(renameColumn2Op);

			Assert.That(renameColumn1Op.Disabled, Is.False);
			Assert.That(renameColumn2Op.Disabled, Is.False);
			Assert.That(renameTableOp.Disabled, Is.False);
			Assert.That(renameColumn2Op.TableName, Is.EqualTo("TABLE"));
			Assert.That(renameColumn1Op.TableName, Is.EqualTo("TABLE"));
		}

		[Test]
		public void ShouldRenameColumnMultipleTimes()
		{
			var columns = new[]
			{
				Column.Int("c1", Nullable.NotNull, null, null, "description"),
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "textimagefilegroup", "filestreamfilegroup", new string[0]);
			var renameColumn1Op = new RenameColumnOperation("SCHEMA", "TABLE", "C1", "C1New");
			var renameColumn2Op = new RenameColumnOperation("SCHEMA", "TABLE", "C1New", "C2");

			renameColumn1Op.Merge(renameColumn2Op);
			op.Merge(renameColumn2Op);

			op.Merge(renameColumn1Op);
			
			Assert.That(renameColumn2Op.Disabled, Is.True);
			Assert.That(renameColumn2Op.Name, Is.EqualTo("C1New"));
			Assert.That(renameColumn2Op.NewName, Is.EqualTo("C2"));

			Assert.That(renameColumn1Op.Disabled, Is.True);
			Assert.That(renameColumn1Op.Name, Is.EqualTo("C1"));
			Assert.That(renameColumn1Op.NewName, Is.EqualTo("C2"));

			Assert.That(op.Disabled, Is.False);
			Assert.That(op.Columns[0].Name, Is.EqualTo("C2"));
		}
	}
}
