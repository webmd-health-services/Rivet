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
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "fileGroup";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };
			var description = "description";

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options, description);
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
			Assert.That(op.Description, Is.EqualTo(description));
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", schemaName, tableName)));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithAllOptionsTrue()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "fileGroup";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };
			var description = "description";

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options, description);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] as FileTable{0}on fileGroup{0}textimage_on textImageFileGroup{0}filestream_on fileGroup{0}with ( option1, option2 )", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}


		[Test]
		public void ShouldWriteQueryForAddTableWithFileTableFalse()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = false;
			var fileGroup = "fileGroup";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };
			var description = "description";

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options, description);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] ({0}    [name] varchar(50) not null constraint [DF_schemaName_tableName_name] default '',{0}    [int column] int identity not null{0}){0}on fileGroup{0}textimage_on textImageFileGroup{0}filestream_on fileGroup{0}with ( option1, option2 )", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldFormatOneColumnTable()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Column[] columnlist = { column1 };

			var op = new AddTableOperation(schemaName, tableName, columnlist, false, null, null, null, null, null);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] ({0}    [name] varchar(50) not null constraint [DF_schemaName_tableName_name] default ''{0})", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoFileGroup()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "textImageFileGroup";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };
			var description = "description";

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options, description);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] as FileTable{0}textimage_on textImageFileGroup{0}filestream_on fileGroup{0}with ( option1, option2 )", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoTextImageFileGroup()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "";
			var fileStremFileGroup = "fileGroup";
			string[] options = new string[] { "option1", "option2" };
			var description = "description";

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options, description);
			var expectedQuery = string.Format(@"create table [schemaName].[tableName] as FileTable{0}filestream_on fileGroup{0}with ( option1, option2 )", Environment.NewLine);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoFileStreamFileGroup()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "";
			var fileStremFileGroup = "";
			string[] options = new string[] { "option1", "option2" };
			var description = "description";

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options, description);
			var expectedQuery = String.Format(@"create table [schemaName].[tableName] as FileTable{0}with ( option1, option2 )", Environment.NewLine);

			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		[Test]
		public void ShouldWriteQueryForAddTableWithNoOptions()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			Identity identity = new Identity();
			var column2 = Column.Int("int column", identity, "test int column");
			Column[] columnlist = new Column[] { column1, column2 };
			bool fileTable = true;
			var fileGroup = "";
			var textImageFileGroup = "";
			var fileStremFileGroup = "";
			string[] options = new string[] { };
			var description = "description";

			var op = new AddTableOperation(schemaName, tableName, columnlist, fileTable, fileGroup, textImageFileGroup, fileStremFileGroup, options, description);
			var expectedQuery = @"create table [schemaName].[tableName] as FileTable";
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));
		}
	}
}
