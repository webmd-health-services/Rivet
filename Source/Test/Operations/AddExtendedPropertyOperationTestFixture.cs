using System;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddExtendedPropertyOperationTestFixture
	{
		private AddExtendedPropertyOperation _op;

		const string SchemaName = "schemaName";
		const string TableName = "tableName";
		const string ViewName = "viewName";
		const string ColumnName = "columnName";
		const string Name = "name";
		const string Value = "value";

		[Test]
		public void ShouldSetPropertiesForAddExtendedPropertyForScheam()
		{
			//For Schema
			var op = new AddExtendedPropertyOperation(SchemaName, Name, Value);
			Assert.AreEqual(true, op.ForSchema);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
		}

		[Test]
		public void ShouldSetPropertiesForAddExtendedPropertyForTable()
		{
			//For Table
			var op = new AddExtendedPropertyOperation(SchemaName, TableName, Name, Value, false);
			Assert.AreEqual(true, op.ForTable);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableViewName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
		}

		[Test]
		public void ShouldSetPropertiesForAddExtendedPropertyForView()
		{
			//For View
			var op = new AddExtendedPropertyOperation(SchemaName, ViewName, Name, Value, true);
			Assert.AreEqual(true, op.ForView);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ViewName, op.TableViewName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
		}

		[Test]
		public void ShouldSetPropertiesForAddExtendedPropertyForColumn()
		{
			//For Column
			var op = new AddExtendedPropertyOperation(SchemaName, TableName, ColumnName, Name, Value, false);
			Assert.AreEqual(true, op.ForColumn);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableViewName);
			Assert.AreEqual(ColumnName, op.ColumnName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
		}

		[Test]
		public void ShouldAllowNullValue()
		{
			GivenSchemaPropertyValue(null);
			ThenValueInQueryShouldBe("null");
			ThenLevel0ShouldBeSchema();
		}

		[Test]
		public void ShouldAllowEmptyStringForValue()
		{
			GivenSchemaPropertyValue("");
			ThenValueInQueryShouldBe("N''");
			ThenLevel0ShouldBeSchema();
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForSchema()
		{
			GivenSchemaPropertyValue(Value);
			ThenValueInQueryShouldBe("N'" + Value + "'");
			ThenLevel0ShouldBeSchema();
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForTable()
		{
			GivenTablePropertyValue();
			ThenValueInQueryShouldBe();
			ThenLevel1ShouldBeTable();
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForView()
		{
			GivenViewPropertyValue();
			ThenValueInQueryShouldBe();
			ThenLevel1ShouldBeView();
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForTableColumn()
		{
			GivenTableColumnPropertyValue();
			ThenValueInQueryShouldBe();
			ThenLevel1ShouldBeTable();
			ThenLevel2ShouldBeColumn();
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForViewColumn()
		{
			GivenViewColumnPropertyValue();
			ThenValueInQueryShouldBe();
			ThenLevel1ShouldBeView();
			ThenLevel2ShouldBeColumn();
		}

		private void ThenValueInQueryShouldBe()
		{
			ThenValueInQueryShouldBe(string.Format("N'{0}'", _op.Value));
		}

		private void ThenValueInQueryShouldBe(string value)
		{
			Assert.That(_op.ToQuery(), Contains.Substring(string.Format("@value={0}", value)));
		}

		private void ThenLevel0ShouldBeSchema()
		{
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

		private void GivenSchemaPropertyValue(string value)
		{
			var schemaName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();

			_op = new AddExtendedPropertyOperation(schemaName, name, value);
		}

		private void GivenTablePropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var tableName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new AddExtendedPropertyOperation(schemaName, tableName, name, value, false);
		}

		private void GivenViewPropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var viewName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new AddExtendedPropertyOperation(schemaName, viewName, name, value, true);
		}

		private void GivenTableColumnPropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var tableName = Guid.NewGuid().ToString();
			var columnName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new AddExtendedPropertyOperation(schemaName, tableName, columnName, name, value, false);
		}

		private void GivenViewColumnPropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var viewName = Guid.NewGuid().ToString();
			var columnName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new AddExtendedPropertyOperation(schemaName, viewName, columnName, name, value, true);

		}
	}
}
