using System;
using System.Diagnostics;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateTableOperationTestFixture
	{

		const string SchemaName = "schemaName";
		const string Name = "name";
		static Column column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
		static Identity identity = new Identity();
		static Column column2 = Column.Int("int column", identity, "test int column");
		private Column[] addColumnList = { column1, column2 };
		private Column[] updateColumnList = {column2, column1};

		[Test]
		public void ShouldSetPropertiesForUpdateTable()
		{
			var op = new UpdateTableOperation(SchemaName, Name, addColumnList, updateColumnList);

			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(addColumnList, op.AddColumns);
			Assert.AreEqual(updateColumnList, op.UpdateColumns);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, Name)));
		}

		[Test]
		public void ShouldWriteQueryForUpdateTableWithAddOnly()
		{
			var op = new UpdateTableOperation(SchemaName, Name, addColumnList, null);

			var expectedQuery =
				string.Format("alter table [schemaName].[name] add [name] varchar(50) not null constraint [DF_schemaName_name_name] default ''{0}alter table [schemaName].[name] add [int column] int identity", Environment.NewLine);

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForUpdateTableWithUpdateOnly()
		{
			var op = new UpdateTableOperation(SchemaName, Name, null, updateColumnList);

			var expectedQuery = 
				string.Format("alter table [schemaName].[name] alter column [int column] int identity{0}alter table [schemaName].[name] alter column [name] varchar(50) not null constraint [DF_schemaName_name_name] default ''", Environment.NewLine);

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForUpdateTableWithAddUpdate()
		{
			var op = new UpdateTableOperation(SchemaName, Name, addColumnList, updateColumnList);

			var expectedQuery = 
				string.Format("alter table [schemaName].[name] add [name] varchar(50) not null constraint [DF_schemaName_name_name] default ''{0}alter table [schemaName].[name] add [int column] int identity{0}alter table [schemaName].[name] alter column [int column] int identity{0}alter table [schemaName].[name] alter column [name] varchar(50) not null constraint [DF_schemaName_name_name] default ''", Environment.NewLine);

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}

}