using System;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveExtendedPropertyOperationTestFixture
	{
		private RemoveExtendedPropertyOperation _op;
		const string SchemaName = "schemaName";
		const string TableName = "tableName";
		const string ViewName = "viewName";
		const string ColumnName = "columnName";
		const string Name = "name";


		[Test]
		public void ShouldSetPropertiesForRemoveExtendedProperty()
		{
			//For Schema
			var op = new RemoveExtendedPropertyOperation(SchemaName, Name);
			Assert.AreEqual(true, op.ForSchema);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.That(op.TableViewObjectName, Is.Empty);

			//For Table
			op = new RemoveExtendedPropertyOperation(SchemaName, TableName, Name, false);
			Assert.AreEqual(true, op.ForTable);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableViewName);
			Assert.AreEqual(Name, op.Name);
			Assert.That(op.TableViewObjectName, Is.EqualTo($"{SchemaName}.{TableName}"));

			//For View
			op = new RemoveExtendedPropertyOperation(SchemaName, ViewName, Name, true);
			Assert.AreEqual(true, op.ForView);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ViewName, op.TableViewName);
			Assert.AreEqual(Name, op.Name);
			Assert.That(op.TableViewObjectName, Is.EqualTo($"{SchemaName}.{ViewName}"));

			//For Column
			op = new RemoveExtendedPropertyOperation(SchemaName, TableName, ColumnName, Name, false);
			Assert.AreEqual(true, op.ForColumn);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableViewName);
			Assert.AreEqual(ColumnName, op.ColumnName);
			Assert.AreEqual(Name, op.Name);
			Assert.That(op.TableViewObjectName, Is.EqualTo($"{SchemaName}.{TableName}"));
		}

		[Test]
		public void ShouldWriteQueryForRemoveExtendedPropertyForSchema()
		{
			GivenSchemaProperty();
			ThenLevel0ShouldBeSchema();
		}

		[Test]
		public void ShouldWriteQueryForRemoveExtendedPropertyForTable()
		{
			GivenTableProperty();
			ThenLevel1ShouldBeTable();
		}

		[Test]
		public void ShouldWriteQueryForRemoveExtendedPropertyForView()
		{
			GivenViewProperty();
			ThenLevel1ShouldBeView();
		}

		[Test]
		public void ShouldWriteQueryForRemoveExtendedPropertyForTableColumn()
		{
			GivenTableColumnProperty();
			ThenLevel1ShouldBeTable();
			ThenLevel2ShouldBeColumn();
		}

		[Test]
		public void ShouldWriteQueryForRemoveExtendedPropertyForViewColumn()
		{
			GivenViewColumnProperty();
			ThenLevel1ShouldBeView();
			ThenLevel2ShouldBeColumn();
		}

		private void ThenNameInQueryShouldBe()
		{
			Assert.That(_op.ToQuery(), Contains.Substring(string.Format("@name=N'{0}'", _op.Name)));
		}

		private void ThenLevel0ShouldBeSchema()
		{
			ThenNameInQueryShouldBe();
			Assert.That(_op.ToQuery(), Contains.Substring(string.Format("@level0type=N'SCHEMA', @level0name=N'{0}'", _op.SchemaName)));
		}

		private void ThenLevel1ShouldBeTable()
		{
			ThenLevel0ShouldBeSchema();
			Assert.That(_op.ToQuery(), Contains.Substring(string.Format("@level1type=N'TABLE', @level1name='{0}'", _op.TableViewName)));
		}

		private void ThenLevel1ShouldBeView()
		{
			ThenLevel0ShouldBeSchema();
			Assert.That(_op.ToQuery(), Contains.Substring(string.Format("@level1type=N'VIEW', @level1name='{0}'", _op.TableViewName)));
		}

		private void ThenLevel2ShouldBeColumn()
		{
			Assert.That(_op.ToQuery(), Contains.Substring(string.Format("@level2type=N'COLUMN', @level2name='{0}'", _op.ColumnName)));
		}

		private void GivenSchemaProperty()
		{
			var schemaName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();

			_op = new RemoveExtendedPropertyOperation(schemaName, name);
		}

		private void GivenTableProperty()
		{
			var schemaName = Guid.NewGuid().ToString();
			var tableName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();

			_op = new RemoveExtendedPropertyOperation(schemaName, tableName, name, false);
		}

		private void GivenViewProperty()
		{
			var schemaName = Guid.NewGuid().ToString();
			var viewName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();

			_op = new RemoveExtendedPropertyOperation(schemaName, viewName, name, true);
		}

		private void GivenTableColumnProperty()
		{
			var schemaName = Guid.NewGuid().ToString();
			var tableName = Guid.NewGuid().ToString();
			var columnName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();

			_op = new RemoveExtendedPropertyOperation(schemaName, tableName, columnName, name, false);
		}

		private void GivenViewColumnProperty()
		{
			var schemaName = Guid.NewGuid().ToString();
			var viewName = Guid.NewGuid().ToString();
			var columnName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();

			_op = new RemoveExtendedPropertyOperation(schemaName, viewName, columnName, name, true);

		}
	}
}
