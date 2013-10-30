﻿using System;
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

		[SetUp]
		public void SetUp()
		{
		}

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
			GivenPropertyValue(null);
			ThenValueInQueryShouldBe("null");
		}

		[Test]
		public void ShouldAllowEmptyStringForValue()
		{
			GivenPropertyValue("");
			ThenValueInQueryShouldBe("N''");
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForSchema()
		{
			GivenPropertyValue(Value);
			ThenValueInQueryShouldBe("N'" + Value + "'");
		}

		private void ThenValueInQueryShouldBe(string value)
		{
			var expectedQuery =
				String.Format(
					"EXEC sys.sp_addextendedproperty{0}@name=N'name',{0}@value={1},{0}@level0type=N'SCHEMA', @level0name=N'schemaName'",
					Environment.NewLine, value);
			Assert.That(_op.ToQuery(), Is.EqualTo(expectedQuery));
		}

		private void GivenPropertyValue(string value)
		{
			_op = new AddExtendedPropertyOperation(SchemaName, Name, value);
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForTable()
		{
			var op = new AddExtendedPropertyOperation(SchemaName, TableName, Name, Value, false);
			var expectedQuery = String.Format("EXEC sys.sp_addextendedproperty{0}@name=N'name',{0}@value=N'value',{0}@level0type=N'SCHEMA', @level0name=N'schemaName',{0}@level1type=N'TABLE', @level1name='tableName'", Environment.NewLine);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForView()
		{
			var op = new AddExtendedPropertyOperation(SchemaName, ViewName, Name, Value, true);
			var expectedQuery = String.Format("EXEC sys.sp_addextendedproperty{0}@name=N'name',{0}@value=N'value',{0}@level0type=N'SCHEMA', @level0name=N'schemaName',{0}@level1type=N'VIEW', @level1name='viewName'", Environment.NewLine);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForTableColumn()
		{
			var op = new AddExtendedPropertyOperation(SchemaName, TableName, ColumnName, Name, Value, false);
			var expectedQuery = String.Format("EXEC sys.sp_addextendedproperty{0}@name=N'name',{0}@value=N'value',{0}@level0type=N'SCHEMA', @level0name=N'schemaName',{0}@level1type=N'TABLE', @level1name='tableName',{0}@level2type=N'COLUMN', @level2name='columnName'", Environment.NewLine);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddExtendedPropertyForViewColumn()
		{
			var op = new AddExtendedPropertyOperation(SchemaName, ViewName, ColumnName, Name, Value, true);
			var expectedQuery = String.Format("EXEC sys.sp_addextendedproperty{0}@name=N'name',{0}@value=N'value',{0}@level0type=N'SCHEMA', @level0name=N'schemaName',{0}@level1type=N'VIEW', @level1name='viewName',{0}@level2type=N'COLUMN', @level2name='columnName'", Environment.NewLine);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}
