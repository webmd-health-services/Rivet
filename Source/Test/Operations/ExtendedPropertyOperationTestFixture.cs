using NUnit.Framework;
using Rivet.Operations;
using System;
using System.Collections.Generic;
using System.Text;

namespace Rivet.Test.Operations
{
    [TestFixture]
    internal sealed class ExtendedPropertyOperationTestFixture
    {
        private class TestExtendedPropertyOperation : ExtendedPropertyOperation
        {
            public TestExtendedPropertyOperation(string schemaName, string name) : base(schemaName, name)
            {
            }

            public TestExtendedPropertyOperation(string schemaName, string tableViewName, string name, bool forView) :
                base(schemaName, tableViewName, name, forView)
            {
            }

            public TestExtendedPropertyOperation(string schemaName, string tableViewName, string columnName,
                string name, bool forView) : base(schemaName, tableViewName, columnName, name, forView)
            {
            }

            public override string ToIdempotentQuery()
            {
                throw new NotImplementedException();
            }

            protected override string StoredProcedureName => "test extended property";
        }

        [Test]
        public void ShouldInitializeForSchema()
        {
            var op = new TestExtendedPropertyOperation("schema", "name");
            Assert.That(op.SchemaName, Is.EqualTo("schema"));
            Assert.That(op.Name, Is.EqualTo("name"));
            Assert.That(op.Value, Is.Null);
            Assert.That(op.ForSchema, Is.True);
            Assert.That(op.TableViewName, Is.Null);
            Assert.That(op.ForTable, Is.False);
            Assert.That(op.ForView, Is.False);
            Assert.That(op.ColumnName, Is.Null);
            Assert.That(op.ForColumn, Is.False);
        }

        [Test]
        public void ShouldInitializeForTable()
        {
            var op = new TestExtendedPropertyOperation("schema", "table", "name", false);
            Assert.That(op.SchemaName, Is.EqualTo("schema"));
            Assert.That(op.Name, Is.EqualTo("name"));
            Assert.That(op.Value, Is.Null);
            Assert.That(op.ForSchema, Is.False);
            Assert.That(op.TableViewName, Is.EqualTo("table"));
            Assert.That(op.ForTable, Is.True);
            Assert.That(op.ForView, Is.False);
            Assert.That(op.ColumnName, Is.Null);
            Assert.That(op.ForColumn, Is.False);
        }

        [Test]
        public void ShouldInitializeForTableColumn()
        {
            var op = new TestExtendedPropertyOperation("schema", "table", "column", "name", false);
            Assert.That(op.SchemaName, Is.EqualTo("schema"));
            Assert.That(op.Name, Is.EqualTo("name"));
            Assert.That(op.Value, Is.Null);
            Assert.That(op.ForSchema, Is.False);
            Assert.That(op.TableViewName, Is.EqualTo("table"));
            Assert.That(op.ForTable, Is.True);
            Assert.That(op.ForView, Is.False);
            Assert.That(op.ColumnName, Is.EqualTo("column"));
            Assert.That(op.ForColumn, Is.True);
        }

        [Test]
        public void ShouldInitializeForView()
        {
            var op = new TestExtendedPropertyOperation("schema", "view", "name", true);
            Assert.That(op.SchemaName, Is.EqualTo("schema"));
            Assert.That(op.Name, Is.EqualTo("name"));
            Assert.That(op.Value, Is.Null);
            Assert.That(op.ForSchema, Is.False);
            Assert.That(op.TableViewName, Is.EqualTo("view"));
            Assert.That(op.ForTable, Is.False);
            Assert.That(op.ForView, Is.True);
            Assert.That(op.ColumnName, Is.Null);
            Assert.That(op.ForColumn, Is.False);
        }

        [Test]
        public void ShouldInitializeForViewColumn()
        {
            var op = new TestExtendedPropertyOperation("schema", "view", "column", "name", true);
            Assert.That(op.SchemaName, Is.EqualTo("schema"));
            Assert.That(op.Name, Is.EqualTo("name"));
            Assert.That(op.Value, Is.Null);
            Assert.That(op.ForSchema, Is.False);
            Assert.That(op.TableViewName, Is.EqualTo("view"));
            Assert.That(op.ForTable, Is.False);
            Assert.That(op.ForView, Is.True);
            Assert.That(op.ColumnName, Is.EqualTo("column"));
            Assert.That(op.ForColumn, Is.True);
        }

        [Test]
        public void ShouldDisableOperationWhenItsTableIsRemoved()
        {
            var op = new AddExtendedPropertyOperation("schema", "table", "name", "value", false);
            var removeTableOp = new RemoveTableOperation("SCHEMA", "TABLE");
            op.Merge(removeTableOp);
            Assert.That(op.Disabled, Is.True);
            Assert.That(removeTableOp.Disabled, Is.False);
        }

        [Test]
        public void ShouldNotDisableOperationWhenItIsForATableAndAViewWithTheSameNameIsRemoved()
        {
            var op = new AddExtendedPropertyOperation("schema", "table", "name", "value", false);
            var removeViewOp = new RemoveViewOperation("SCHEMA", "TABLE");
            op.Merge(removeViewOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(removeViewOp.Disabled, Is.False);
        }

        [Test]
        public void ShouldDisableOperationWhenItsViewIsRemoved()
        {
            var op = new AddExtendedPropertyOperation("schema", "view", "name", "value", true);
            var removeViewOp = new RemoveViewOperation("SCHEMA", "VIEW");
            op.Merge(removeViewOp);
            Assert.That(op.Disabled, Is.True);
            Assert.That(removeViewOp.Disabled, Is.False);
        }

        [Test]
        public void ShouldNotDisableOperationWhenItsIsForAViewAndATableWithTheSameNameIsRemoved()
        {
            var op = new AddExtendedPropertyOperation("schema", "view", "name", "value", true);
            var removeTableOp = new RemoveTableOperation("SCHEMA", "VIEW");
            op.Merge(removeTableOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(removeTableOp.Disabled, Is.False);
        }

        [Test]
        public void ShouldDisableOperationWhenItsColumnIsRemoved()
        {
            var op = new AddExtendedPropertyOperation("schema", "table", "column", "name", "value", false);
            var updateTableOp = new UpdateTableOperation("SCHEMA", "TABLE", new Column[0], new Column[0], new[] { "COLUMN" });
            op.Merge(updateTableOp);
            Assert.That(op.Disabled, Is.True);
            Assert.That(updateTableOp.Disabled, Is.False);
        }

        [Test]
        public void ShouldUpdateOperationIfTableIsRenamed()
        {
            var op = new AddExtendedPropertyOperation("schema", "table", "name", "value", false);
            var renameOp = new RenameObjectOperation("SCHEMA", "TABLE", "newtable");
            op.Merge(renameOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(renameOp.Disabled, Is.False);
            Assert.That(op.TableViewName, Is.EqualTo("newtable"));
        }

        [Test]
        public void ShouldUpdateOperationIfViewIsRenamed()
        {
            var op = new AddExtendedPropertyOperation("schema", "view", "name", "value", true);
            var renameOp = new RenameObjectOperation("SCHEMA", "VIEW", "newview");
            op.Merge(renameOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(renameOp.Disabled, Is.False);
            Assert.That(op.TableViewName, Is.EqualTo("newview"));
        }

        [Test]
        public void ShouldRemoveIfTableColumnIsRemoved()
        {
            var op = new AddExtendedPropertyOperation("schema", "table", "column", "name", "value", false);
            var renameOp = new RenameColumnOperation("SCHEMA", "TABLE", "COLUMN", "newcolumn");
            op.Merge(renameOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(renameOp.Disabled, Is.False);
            Assert.That(op.ColumnName, Is.EqualTo("newcolumn"));
        }

        [Test]
        public void ShouldRemoveIfAddingSchemaPropertyAndSchemaGettingRemoved()
        {
            var op = new AddExtendedPropertyOperation("schema", "name", "value");
            var removeSchemaOp = new RemoveSchemaOperation("SCHEMA");
            op.Merge(removeSchemaOp);
            Assert.That(op.Disabled, Is.True);
            Assert.That(removeSchemaOp.Disabled, Is.False);
        }

        [Test]
        public void ShouldRemoveIfUpdatingSchemaPropertyAndSchemaGettingRemoved()
        {
            var op = new UpdateExtendedPropertyOperation("schema", "name", "value");
            var removeSchemaOp = new RemoveSchemaOperation("SCHEMA");
            op.Merge(removeSchemaOp);
            Assert.That(op.Disabled, Is.True);
            Assert.That(removeSchemaOp.Disabled, Is.False);
        }

        [Test]
        public void ShouldRemoveIfRemovingSchemaPropertyAndSchemaGettingRemoved()
        {
            var op = new RemoveExtendedPropertyOperation("schema", "name");
            var removeSchemaOp = new RemoveSchemaOperation("SCHEMA");
            op.Merge(removeSchemaOp);
            Assert.That(op.Disabled, Is.True);
            Assert.That(removeSchemaOp.Disabled, Is.False);
        }
    }
}
