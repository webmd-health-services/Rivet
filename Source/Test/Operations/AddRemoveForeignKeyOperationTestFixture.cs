using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemoveForeignKeyConstraintTestFixture
	{
		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForAddForeignKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			string[] referencesColumnName = new string[] { "rcolumn1", "rcolumn2" };
			string[] smokeReferencesColumnName = new string[] { "rcolumn1" };
			var referencesSchemaName = "rschemaName";
			var referencesTableName = "rtableName";
			var onDelete = "onDelete";
			var onUpdate = "onUpdate";
			bool notForReplication = true;

			var op = new AddForeignKeyOperation(schemaName, tableName, columnName, referencesSchemaName, referencesTableName, referencesColumnName, onDelete, onUpdate, notForReplication);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(referencesColumnName, op.ReferencesColumnName);
			Assert.AreNotEqual(smokeReferencesColumnName, op.ReferencesColumnName);
			Assert.AreEqual(referencesSchemaName, op.ReferencesSchemaName);
			Assert.AreEqual(referencesTableName, op.ReferencesTableName);
			Assert.AreEqual(onDelete, op.OnDelete);
			Assert.AreEqual(onUpdate, op.OnUpdate);
			Assert.AreEqual(notForReplication, op.NotForReplication);
		}

		[Test]
		public void ShouldWriteQueryForAddForeignKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] referencesColumnName = new string[] { "rcolumn1", "rcolumn2" };
			var referencesSchemaName = "rschemaName";
			var referencesTableName = "rtableName";
			var onDelete = "onDelete";
			var onUpdate = "onUpdate";
			bool notForReplication = true;

			var op = new AddForeignKeyOperation(schemaName, tableName, columnName, referencesSchemaName, referencesTableName, referencesColumnName, onDelete, onUpdate, notForReplication);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint FK_schemaName_tableName_rschemaName_rtableName foreign key (column1,column2) references rschemaName.rtableName (rcolumn1,rcolumn2) on delete onDelete on update onUpdate not for replication";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}

}