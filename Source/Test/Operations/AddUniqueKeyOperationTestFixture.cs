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
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			bool clustered = true;
			int fillfactor = 2;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeOptions = new string[] { "option2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(fillfactor, op.FillFactor);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(fileGroup, op.FileGroup);
			Assert.That(op.ObjectName, Is.EqualTo($"{schemaName}.AK_{schemaName}_{tableName}_{string.Join("_", columnName)}"));
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

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
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

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, customConstraintName, clustered, fillfactor, options, fileGroup);
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

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [AK_schemaName_tableName_column1_column2] unique clustered ([column1], [column2]) on fileGroup";
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

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, customConstraintName, clustered, fillfactor, options, fileGroup);
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

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [AK_schemaName_tableName_column1_column2] unique clustered ([column1], [column2]) with (option1, option2) on fileGroup";
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

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [AK_schemaName_tableName_column1_column2] unique clustered ([column1], [column2]) with (fillfactor = 80) on fileGroup";
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

			var op = new AddUniqueKeyOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table [schemaName].[tableName] add constraint [AK_schemaName_tableName_column1_column2] unique clustered ([column1], [column2]) with (option1, options2, fillfactor = 80) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			var op = new AddUniqueKeyOperation("schema", "table", new[] { "column" }, false, 0, null, null);
			op.Name = "new name";
			Assert.That(op.Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveOperation()
		{
			var op = new AddUniqueKeyOperation("schema", "table", new string[0], "name", false, 0, new string[0], "filegroup");
			var removeOp = new RemoveUniqueKeyOperation("SCHEMA", "TABLE", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}
	}
}