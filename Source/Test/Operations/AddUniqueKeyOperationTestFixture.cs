using System;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddUniqueKeyTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForAddUniqueConstraint()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };
			const bool clustered = true;
			const int fillFactor = 2;
			var options = new[] { "option1", "option2" };
			var smokeOptions = new[] { "option2" };
			const string fileGroup = "fileGroup";
			const string name = "constraint_name";

			var op = new AddUniqueKeyOperation(schemaName, tableName, name, columnName, clustered, fillFactor, options, fileGroup);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.Name, Is.EqualTo(name));
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(fillFactor, op.FillFactor);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(fileGroup, op.FileGroup);
			Assert.That(op.ObjectName, Is.EqualTo($"{schemaName}.{name}"));
			Assert.That(op.TableObjectName, Is.EqualTo($"{schemaName}.{tableName}"));
			Assert.That(op.ConstraintType, Is.EqualTo(ConstraintType.UniqueKey));
		}

		[Test]
		public void ShouldSetPropertiesWithNullOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			bool clustered = true;
			int fillfactor = 2;
			string[] options = null;
			string[] smokeOptions = new string[] { "option2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, "name", columnName, clustered, fillfactor, options, fileGroup);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.That(op.Name, Is.EqualTo("name"));
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(fillfactor, op.FillFactor);
			Assert.AreEqual("", op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(fileGroup, op.FileGroup);
		}

		[Test]
		public void ShouldSetPropertiesForAddUniqueConstraintWithCustomName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			var customConstraintName = "customConstraintName";
			bool clustered = true;
			int fillfactor = 2;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeOptions = new string[] { "option2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, customConstraintName, columnName, clustered, fillfactor, options, fileGroup);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(customConstraintName, op.Name.ToString());
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(fillfactor, op.FillFactor);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(fileGroup, op.FileGroup);
		}

		[Test]
		public void ShouldWriteQueryForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 0;
			string[] options = null;
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, "name", columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [name] unique clustered ([column1], [column2]) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddUniqueConstraintWithCustomName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			var customConstraintName = "customConstraintName";
			bool clustered = true;
			int fillfactor = 0;
			string[] options = null;
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, customConstraintName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [customConstraintName] unique clustered ([column1], [column2]) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 0;
			string[] options = new string[] { "option1", "option2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, "name", columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [name] unique clustered ([column1], [column2]) with (option1, option2) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
		

		[Test]
		public void ShouldWriteQueryWithNoOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 80;
			string[] options = null;
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, "name", columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [name] unique clustered ([column1], [column2]) with (fillfactor = 80) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithFillFactorAndOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 80;
			string[] options = new string[] { "option1", "options2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, "name", columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [name] unique clustered ([column1], [column2]) with (option1, options2, fillfactor = 80) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			var op = new AddUniqueKeyOperation("schema", "table", "name", new[] { "column" }, false, 0, null, null);
			op.Name = "new name";
			Assert.That(op.Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveOperation()
		{
			var op = new AddUniqueKeyOperation("schema", "table", "name", new string[0], false, 0, new string[0], "filegroup");
			var removeOp = new RemoveUniqueKeyOperation("SCHEMA", "TABLE", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}
	}
}