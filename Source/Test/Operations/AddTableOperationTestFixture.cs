using System;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddTableOperationTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForAddTable()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "fileGroup";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options);
			Assert.That(op.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op.Name, Is.EqualTo(tableName));
			Assert.That(op.Columns.Contains(column1));
			Assert.That(op.Columns.Contains(column2));
			Assert.That(op.Columns.Count, Is.EqualTo(2));
			Assert.That(op.FileTable, Is.EqualTo(true));
			Assert.That(op.FileGroup, Is.EqualTo(fileGroup));
			Assert.That(op.TextImageFileGroup, Is.EqualTo(textImageFileGroup));
			Assert.That(op.FileStreamFileGroup, Is.EqualTo(fileStremFileGroup));
			Assert.That(op.Options.Contains("option1"));
			Assert.That(op.Options.Contains("option2"));
			Assert.That(op.Options.Count, Is.EqualTo(2));
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", schemaName, tableName)));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithAllOptionsTrue()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "fileGroup";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] as FileTable{0}on fileGroup{0}textimage_on textImageFileGroup{0}filestream_on fileGroup{0}with ( option1, option2 )", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}


		[Test]
		public void ShouldWriteQueryForAddTableWithFileTableFalse()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = false;
			var fileGroup = "fileGroup";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options);
			var expectedQuery = 
				$@"create table [schemaName].[tableName] ({Environment.NewLine}" + 
				$"    [name] varchar(50) not null constraint [default constraint name] default '',{Environment.NewLine}" + 
				$"    [int column] int identity not null{Environment.NewLine})" + 
				$"{Environment.NewLine}" + 
				$"on fileGroup{Environment.NewLine}" + 
				$"textimage_on textImageFileGroup{Environment.NewLine}" + 
				$"filestream_on fileGroup{Environment.NewLine}" + 
"with ( option1, option2 )";

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldFormatOneColumnTable()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Column[] columnlist = { column1 };

			var op = new AddTableOperation(schemaName, tableName, columnlist, false, null, null, null, null);
			var expectedQuery =
				$@"create table [schemaName].[tableName] ({Environment.NewLine}" + 
				$"    [name] varchar(50) not null constraint [default constraint name] default ''{Environment.NewLine})";

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoFileGroup()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] as FileTable{0}textimage_on textImageFileGroup{0}filestream_on fileGroup{0}with ( option1, option2 )", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoTextImageFileGroup()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options);
			var expectedQuery = string.Format(@"create table [schemaName].[tableName] as FileTable{0}filestream_on fileGroup{0}with ( option1, option2 )", Environment.NewLine);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoFileStreamFileGroup()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "";
			var fileStremFileGroup = "";
			string[] options = new string[] { "option1", "option2" };

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] as FileTable{0}with ( option1, option2 )", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoOptions()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "default constraint name", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "";
			var fileStremFileGroup = "";
			string[] options = new string[] { };

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options);
			var expectedQuery = @"create table [schemaName].[tableName] as FileTable";
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveOperation()
		{
			var op = new AddTableOperation("schema", "name", new Column[0], false, "filegroup", "textimagefilegroup", "filestreamgroup", new string[0]);
			var removeOp = new RemoveTableOperation("SCHEMA", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}

		[Test]
		public void ShouldReplaceColumnsIfUpdatedByMerge()
		{
			var columns = new Column[]
			{
				Column.Int("id", null, "description"),
				Column.VarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description"),
				Column.Char("flag", new CharacterLength(1), "collation", Nullable.NotNull, null, null, "description")
			};
			var op = new AddTableOperation("schema", "table", columns, false, "filegroup", "textimagefilegroup", "filetreamfilegroup", new string[0]);

			var updatedColumns = new Column[]
			{
				Column.BigInt("ID", new Identity(), "new_description"),
				Column.NVarChar("NAME", new CharacterLength(25), "new collation", Nullable.NotNull, "default", "default constraint name", "new description"),
				Column.NVarChar("donotexist", new CharacterLength(25), "new collation", Nullable.NotNull, "default", "default constraint name", "new description")
			};
			var updateOp = new UpdateTableOperation("schema", "table", null, updatedColumns, null);
			op.Merge(updateOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(updateOp.Disabled, Is.True);
			Assert.That(op.Columns[0], Is.SameAs(updatedColumns[0]));
			Assert.That(op.Columns[1], Is.SameAs(updatedColumns[1]));
			Assert.That(op.Columns[2], Is.SameAs(columns[2]));
		}

		[Test]
		public void ShouldAddColumnsIfUpdatedByMerge()
		{
			var columns = new Column[]
			{
				Column.Int("id", null, "description"),
				Column.VarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description"),
			};
			var op = new AddTableOperation("schema", "table", columns, false, "filegroup", "textimagefilegroup", "filetreamfilegroup", new string[0]);

			var newColumns = new Column[]
			{
				Column.BigInt("third", new Identity(), "new_description"),
				Column.NVarChar("fourth", new CharacterLength(25), "new collation", Nullable.NotNull, "default", "default constraint name", "description")
			};
			var updateOp = new UpdateTableOperation("schema", "table", newColumns, null, null);
			op.Merge(updateOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(updateOp.Disabled, Is.True);
			Assert.That(op.Columns[0], Is.SameAs(columns[0]));
			Assert.That(op.Columns[1], Is.SameAs(columns[1]));
			Assert.That(op.Columns[2], Is.SameAs(newColumns[0]));
			Assert.That(op.Columns[3], Is.SameAs(newColumns[1]));
		}

		[Test]
		public void ShouldDeleteColumnsIfDeletedByMerge()
		{
			var columns = new []
			{
				Column.Int("id", null, "description"),
				Column.VarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description"),
				Column.Char("flag", new CharacterLength(1), "collation", Nullable.NotNull, null, null, "description")
			};
			var op = new AddTableOperation("schema", "table", columns, false, "filegroup", "textimagefilegroup", "filetreamfilegroup", new string[0]);

			var updateOp = new UpdateTableOperation("schema", "table", null, null, new string[]{ "ID", "NAME", "IDONOTEXIST" });
			op.Merge(updateOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(updateOp.Disabled, Is.True);
			Assert.That(op.Columns.Count, Is.EqualTo(1));
			Assert.That(op.Columns[0], Is.SameAs(columns[2]));
		}

		[Test]
		public void ShouldRenameColumnsIfRenamedByMerge()
		{
			var columns = new []
			{
				Column.Int("id", null, "description"),
				Column.VarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description")
			};
			var op = new AddTableOperation("schema", "table", columns, false, "filegroup", "textimagefilegroup", "filestreamfilegroup", new string[0]);
			var renameColumnOp = new RenameColumnOperation("SCHEMA", "TABLE", "NAME", "newname");
			op.Merge(renameColumnOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameColumnOp.Disabled, Is.True);
			Assert.That(columns[0].Name, Is.EqualTo("id"));
			Assert.That(columns[1].Name, Is.EqualTo("newname"));
		}

		[Test]
		public void ShouldAddDefaultExpressionIfAddedByMerge()
		{
			var columns = new Column[]
			{
				Column.Int("id", null, "description"),
				Column.VarChar("column", new CharacterLength(50), "collation", Nullable.Null, null, null, "description")
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "textimagefilegroup", "filestreamfilegroup", new string[0]);
			var addDefaultConstraintOp = 
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "NAME", "COLUMN", "default", false);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.True);
			Assert.That(columns[0].DefaultExpression, Is.Null);
			Assert.That(columns[1].DefaultExpression, Is.EqualTo("default"));
		}

		[Test]
		public void ShouldNotAddDefaultExpressionIfUsingWithValuesClauseWhenMerging()
		{
			var columns = new Column[]
			{
				Column.Int("id", null, "description"),
				Column.VarChar("column", new CharacterLength(50), "collation", Nullable.Null, null, null, "description")
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "text image file group", "filestreamfilegroup", new string[0]);
			var addDefaultConstraintOp = 
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "NAME", "COLUMN", "default", true);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.False);
			Assert.That(columns[0].DefaultExpression, Is.Null);
			Assert.That(columns[1].DefaultExpression, Is.Null);
		}

		[Test]
		[TestCase("COLUMN")]
		[TestCase(null)]
		[TestCase("")]
		public void ShouldRemoveDefaultExpressionWhenMergingRemoveDefaultConstraint(string columnName)
		{
			var columns = new Column[]
			{
				Column.Int("id", null, "description"),
				Column.VarChar("column", new CharacterLength(50), "collation", Nullable.Null, "default", "default constraint name", "description")
			};
			var op = new AddTableOperation("schema", "table", columns, false, "filegroup", "textimagefilegroup", "filestreamfilegroup", new string[0]);
			var addDefaultConstraintOp = new RemoveDefaultConstraintOperation("SCHEMA", "TABLE", columnName, "NAME");
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			if( String.IsNullOrEmpty(columnName) )
			{
				Assert.That(addDefaultConstraintOp.Disabled, Is.False);
				Assert.That(columns[0].DefaultExpression, Is.Null);
				Assert.That(columns[1].DefaultExpression, Is.EqualTo("default"));
			}
			else
			{
				Assert.That(addDefaultConstraintOp.Disabled, Is.True);
				Assert.That(columns[0].DefaultExpression, Is.Null);
				Assert.That(columns[1].DefaultExpression, Is.Null);
			}
		}

		[Test]
		public void ShouldAddRowGuidColToColumnWhenMergingAddRowGuidColumnOperation()
		{
			var columns = new Column[]
			{
				Column.UniqueIdentifier("name", false, Nullable.NotNull, "default expression", "default constraint name", "description"),
				Column.UniqueIdentifier("name2", false, Nullable.NotNull, "default expression", "default constraint name", "description"),
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "text image file group", "file stream file group", new string[0]);
			var addRowGuidColOp = new AddRowGuidColOperation("SCHEMA", "TABLE", "name");
			op.Merge(addRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addRowGuidColOp.Disabled, Is.True);
			Assert.That(op.Columns[0].RowGuidCol, Is.True);
			Assert.That(op.Columns[1].RowGuidCol, Is.False);
		}

		[Test]
		public void ShouldNotAddRowGuidColToColumnIfAddRowGuidColumnIsNotUniqueIdentifier()
		{
			var columns = new Column[]
			{
				Column.NVarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description"),
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "text image file group", "file stream file group", new string[0]);
			var addRowGuidColOp = new AddRowGuidColOperation("SCHEMA", "TABLE", "name");
			op.Merge(addRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addRowGuidColOp.Disabled, Is.False);
			Assert.That(op.Columns[0].RowGuidCol, Is.False);
		}

		[Test]
		public void ShouldRemoveRowGuidColFromColumnWhenMergingRemoveRowGuidColumnOperation()
		{
			var columns = new Column[]
			{
				Column.UniqueIdentifier("name", true, Nullable.NotNull, "default expression", "default constraint name", "description"),
				Column.UniqueIdentifier("name2", true, Nullable.NotNull, "default expression", "default constraint name", "description"),
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "text image file group", "file stream file group", new string[0]);
			var addRowGuidColOp = new RemoveRowGuidColOperation("SCHEMA", "TABLE", "name");
			op.Merge(addRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addRowGuidColOp.Disabled, Is.True);
			Assert.That(op.Columns[0].RowGuidCol, Is.False);
			Assert.That(op.Columns[1].RowGuidCol, Is.True);
		}

		[Test]
		public void ShouldNotRemoveRowGuidColFromColumnWhenMergingRemoveRowGuidColumnOperationAndTheColumnIsNotAUniqueIdentifier()
		{
			var columns = new Column[]
			{
				Column.NVarChar("name", new CharacterLength(50), "collation", Nullable.Null, null, null, "description"),
			};
			var op = new AddTableOperation("schema", "table", columns, false, "file group", "text image file group", "file stream file group", new string[0]);
			var addRowGuidColOp = new AddRowGuidColOperation("SCHEMA", "TABLE", "name");
			op.Merge(addRowGuidColOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addRowGuidColOp.Disabled, Is.False);
			Assert.That(op.Columns[0].RowGuidCol, Is.False);
		}

		[Test]
		public void ShouldMergeWithUpdateTableOperationOnce()
		{
			var columns = new[]
			{
				Column.Int("ID", Nullable.NotNull, null, null, null),
				Column.VarChar("Name", new CharacterLength(500), null, Nullable.NotNull, null, null, null),
			};
			var addTableOp = new AddTableOperation("skma", "Farmers", columns, false, null, null, null, new string[0]);
			var updateNameColumnOp = new UpdateTableOperation("skma", "Farmers",
				new[] { Column.VarChar("NAME", new CharacterLength(50), null, Nullable.NotNull, null, null, null) }, null,
				null);
			var updateZipColumnOp = new UpdateTableOperation("skma", "Farmers",
				new[] { Column.VarChar("Zip", new CharacterLength(10), null, Nullable.Null, null, null, null) }, null, null);
			var renameZipColumnOp = new RenameColumnOperation("skma", "Farmers", "ZIP", "ZipCode");
			updateZipColumnOp.Merge(renameZipColumnOp);
			updateNameColumnOp.Merge(renameZipColumnOp);
			addTableOp.Merge(renameZipColumnOp);

			updateNameColumnOp.Merge(updateZipColumnOp);
			addTableOp.Merge(updateZipColumnOp);

			addTableOp.Merge(updateNameColumnOp);
			Assert.That(addTableOp.Disabled, Is.False);
			Assert.That(updateNameColumnOp.Disabled, Is.True);
			Assert.That(updateZipColumnOp.Disabled, Is.True);
			Assert.That(renameZipColumnOp.Disabled, Is.True);
			Assert.That(addTableOp.Columns.Count, Is.EqualTo(3));
			Assert.That(addTableOp.Columns[0].Name, Is.EqualTo("ID"));
			Assert.That(addTableOp.Columns[1].Name, Is.EqualTo("NAME"));
			Assert.That(addTableOp.Columns[2].Name, Is.EqualTo("ZipCode"));
		}

		[Test]
		public void ShouldMergeDefaultConstraintNameWhenMergingAddDefaultConstraintOp()
		{
			var columns = new[]
			{
				Column.Int("ID", Nullable.NotNull, null, null, null),
				Column.VarChar("Name", new CharacterLength(500), null, Nullable.NotNull, null, null, null),
			};
			var op = new AddTableOperation("schema", "table", columns, false, null, null, null, new string[0]);
			var addDefaultConstraintOp =
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "DF_NAME", "NAME", "expression", false);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.True);
			Assert.That(op.Columns[0].DefaultExpression, Is.Null);
			Assert.That(op.Columns[0].DefaultConstraintName, Is.Null);
			Assert.That(op.Columns[1].DefaultExpression, Is.EqualTo("expression"));
			Assert.That(op.Columns[1].DefaultConstraintName, Is.EqualTo("DF_NAME"));
		}

		[Test]
		public void ShouldNotMergeDefaultConstraintNameWhenMergingAddDefaultConstraintWithValuesOp()
		{
			var columns = new[]
			{
				Column.Int("ID", Nullable.NotNull, null, null, null),
				Column.VarChar("Name", new CharacterLength(500), null, Nullable.NotNull, null, null, null),
			};
			var op = new AddTableOperation("schema", "table", columns, false, null, null, null, new string[0]);
			var addDefaultConstraintOp =
				new AddDefaultConstraintOperation("SCHEMA", "TABLE", "DF_NAME", "NAME", "expression", true);
			op.Merge(addDefaultConstraintOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(addDefaultConstraintOp.Disabled, Is.False);
			Assert.That(op.Columns[0].DefaultExpression, Is.Null);
			Assert.That(op.Columns[0].DefaultConstraintName, Is.Null);
			Assert.That(op.Columns[1].DefaultExpression, Is.Null);
			Assert.That(op.Columns[1].DefaultConstraintName, Is.Null);
		}
	}
}
