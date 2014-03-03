using System;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateExtendedPropertyOperationTestFixture
	{
		private UpdateExtendedPropertyOperation _op;

		const string SchemaName = "schemaName";
		const string TableName = "tableName";
		const string ViewName = "viewName";
		const string ColumnName = "columnName";
		const string Name = "name";
		const string Value = "value";

		[SetUp]
		public void SetUp()
		{
		}

		[Test]
		public void ShouldAllowNullValue()
		{
			GivenPropertyValue(null);
			ThenValueInQueryShouldBe("null");
		}

		[Test]
		public void ShouldAllowEmptyStringForValue()
		{
			GivenPropertyValue("");
			ThenValueInQueryShouldBe("N''");
			ThenLevel0ShouldBeSchema();
		}

		[Test]
		public void ShouldQuoteValue()
		{
			GivenPropertyValue(Value);
			ThenValueInQueryShouldBe("N'" + Value + "'");
			ThenLevel0ShouldBeSchema();
		}

		[Test]
		public void ShouldSetPropertiesForUpdateExtendedProperty()
		{
			//For Schema
			var op = new UpdateExtendedPropertyOperation(SchemaName, Name, Value);
			Assert.AreEqual(true, op.ForSchema);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
			Assert.That(op.ObjectName, Is.EqualTo(SchemaName + ".@" + Name));

			//For Table
			op = new UpdateExtendedPropertyOperation(SchemaName, TableName, Name, Value, false);
			Assert.AreEqual(true, op.ForTable);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableViewName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
			Assert.That(op.ObjectName, Is.EqualTo(SchemaName + "." + TableName + ".@" + Name));

			//For View
			op = new UpdateExtendedPropertyOperation(SchemaName, ViewName, Name, Value, true);
			Assert.AreEqual(true, op.ForView);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(ViewName, op.TableViewName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
			Assert.That(op.ObjectName, Is.EqualTo(SchemaName + "." + ViewName + ".@" + Name));

			//For Column
			op = new UpdateExtendedPropertyOperation(SchemaName, TableName, ColumnName, Name, Value, false);
			Assert.AreEqual(true, op.ForColumn);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TableName, op.TableViewName);
			Assert.AreEqual(ColumnName, op.ColumnName);
			Assert.AreEqual(Name, op.Name);
			Assert.AreEqual(Value, op.Value);
			Assert.That(op.ObjectName, Is.EqualTo(SchemaName + "." + TableName + "." + ColumnName + ".@" + Name));
		}

		[Test]
		public void ShouldWriteQueryForUpdateExtendedPropertyForSchema()
		{
			GivenPropertyValue();
			ThenLevel0ShouldBeSchema();
		}

		[Test]
		public void ShouldWriteQueryForUpdateExtendedPropertyForTable()
		{
			GivenTablePropertyValue();
			ThenLevel1ShouldBeTable();
		}

		[Test]
		public void ShouldWriteQueryForUpdateExtendedPropertyForView()
		{
			GivenViewPropertyValue();
			ThenLevel1ShouldBeView();
		}

		[Test]
		public void ShouldWriteQueryForUpdateExtendedPropertyForTableColumn()
		{
			GivenTableColumnPropertyValue();
			ThenLevel1ShouldBeTable();
			ThenLevel2ShouldBeColumn();
		}

		[Test]
		public void ShouldWriteQueryForUpdateExtendedPropertyForViewColumn()
		{
			GivenViewColumnPropertyValue();
			ThenLevel1ShouldBeView();
			ThenLevel2ShouldBeColumn();
		}

		private void GivenPropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();
			_op = new UpdateExtendedPropertyOperation(schemaName, Name, value);
		}

		private void GivenPropertyValue(string value)
		{
			var schemaName = Guid.NewGuid().ToString();
			_op = new UpdateExtendedPropertyOperation(schemaName, Name, value);
		}

		private void ThenQueryShouldHaveValue()
		{
			ThenValueInQueryShouldBe(string.Format("N'{0}'", _op.Value));
		}

		private void ThenValueInQueryShouldBe(string value)
		{
			Assert.That(_op.ToQuery(), Contains.Substring(string.Format("@name=N'{0}', @value={1}",_op.Name,value)));
		}

		private void ThenLevel0ShouldBeSchema()
		{
			ThenQueryShouldHaveValue();
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

		private void GivenTablePropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var tableName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new UpdateExtendedPropertyOperation(schemaName, tableName, name, value, false);
		}

		private void GivenViewPropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var viewName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new UpdateExtendedPropertyOperation(schemaName, viewName, name, value, true);
		}

		private void GivenTableColumnPropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var tableName = Guid.NewGuid().ToString();
			var columnName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new UpdateExtendedPropertyOperation(schemaName, tableName, columnName, name, value, false);
		}

		private void GivenViewColumnPropertyValue()
		{
			var schemaName = Guid.NewGuid().ToString();
			var viewName = Guid.NewGuid().ToString();
			var columnName = Guid.NewGuid().ToString();
			var name = Guid.NewGuid().ToString();
			var value = Guid.NewGuid().ToString();

			_op = new UpdateExtendedPropertyOperation(schemaName, viewName, columnName, name, value, true);

		}
	}
}
