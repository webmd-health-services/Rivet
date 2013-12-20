using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddDataTypeOperationTestFixture
	{

		private const string SchemaName = "schemaName";
		private const string Name = "name";
		private const string From = "uniqueidentifier";
		private const string AssemblyName = "assemblyName";
		private const string ClassName = "className";
		static Column column1 = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
		static readonly Identity Identity = new Identity();
		static Column column2 = Column.Int("int column", Identity, "test int column");
		static Column[] AsTable = { column1, column2 };
		string[] TableConstraint = { "constraint1", "constraint2" };

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForAddDataTypeAlias()
		{
			var op = new AddDataTypeOperation(SchemaName, Name, From);

			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(From, op.From);
		}

		[Test]
		public void ShouldSetPropertiesForAddDataTypeUserDefinedType()
		{
			var op = new AddDataTypeOperation(SchemaName, Name, AssemblyName, ClassName);

			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(AssemblyName, op.AssemblyName);
			Assert.AreEqual(ClassName, op.ClassName);
		}

		[Test]
		public void ShouldSetPropertiesForAddDataTypeUserDefinedTableType()
		{
			var op = new AddDataTypeOperation(SchemaName, Name, AsTable, TableConstraint);

			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(AsTable, op.AsTable);
			Assert.AreEqual(TableConstraint, op.TableConstraint);
		}

		[Test]
		public void ShouldWriteQueryForAddDataTypeAlias()
		{
			var op = new AddDataTypeOperation(SchemaName, Name, From);

			var expectedQuery = "create type [schemaName].[name] from uniqueidentifier";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddDataTypeUserDefinedType()
		{
			var op = new AddDataTypeOperation(SchemaName, Name, AssemblyName, ClassName);

			var expectedQuery = "create type [schemaName].[name] external name assemblyName.[className]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddDataTypeUserDefinedTableType()
		{
			var op = new AddDataTypeOperation(SchemaName, Name, AsTable, TableConstraint);
			var expectedQuery =
				"create type [schemaName].[name] as table ([name] varchar(50) not null constraint [DF_schemaName_name_name] default '', [int column] int identity constraint1, constraint2)";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}

}
