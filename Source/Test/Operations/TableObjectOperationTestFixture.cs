using NUnit.Framework;
using Rivet.Operations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Test.Operations
{
    [TestFixture]
    internal sealed class TableObjectOperationTestFixture
    {

        private class TestTableOperation : TableObjectOperation
        {
            public TestTableOperation(string schemaName, string tableName, string name) : base(schemaName, tableName, name)
            {
            }

            public MergeResult MergeResult { get; private set; }

            public Operation OtherOperation { get; private set; }

            protected override MergeResult DoMerge(Operation op)
            {
                MergeResult = base.DoMerge(op);

                OtherOperation = op;
                return MergeResult.Continue;
            }

            public override string ToIdempotentQuery()
            {
                throw new NotImplementedException();
            }

            public override string ToQuery()
            {
                throw new NotImplementedException();
            }
        }


        [Test]
        [TestCase("schema2", "table")]
        [TestCase("schema", "table2")]
        public void ShouldNotMergeIfTableOperationsOnDifferentTable(string otherSchemaName, string otherTableName)
        {
            var op = new TestTableOperation("schema", "table", "name");
            var otherOp = new TestTableOperation(otherSchemaName, otherTableName, "NAME");
            op.Merge(otherOp);
            Assert.That(op.MergeResult, Is.EqualTo(MergeResult.Stop));
        }

        [Test]
        public void ShouldMergeIfTableOperationsOnSameTable()
        {
            var op = new TestTableOperation("schema", "table", "name");
            var otherOp = new TestTableOperation("SCHEMA", "TABLE", "NAME");
            op.Merge(otherOp);
            Assert.That(op.MergeResult, Is.EqualTo(MergeResult.Continue));
            Assert.That(op.OtherOperation, Is.SameAs(otherOp));
        }

        [Test]
        public void ShouldDisableObjectOperationIfPartOfARemovedTable()
        {
            var tableObjectOps = new TableObjectOperation[]
            {
                new AddCheckConstraintOperation("schema", "table", "column", "expression", false, false),
                new AddDefaultConstraintOperation("schema", "table", "name", "column", "expression", false),
                new AddForeignKeyOperation("schema", "table", new[] { "column" }, "ref_schema", "ref_table", new[] { "ref_column" }, "onDelete", "onUpdate", false, false),
                new AddIndexOperation("schema", "table", null, false, false, null, null, null, null, null),
                new AddPrimaryKeyOperation("schema", "table", "name", new[] { "column" }, false, new string[0]),
                new AddRowGuidColOperation("schema", "table", "column"),
                new AddUniqueKeyOperation("schema", "table", "name", new[] { "column" }, false, 0, new string[0], "filegroup"),
                new DisableConstraintOperation("schema", "table", "name"),
                new EnableConstraintOperation("schema", "table", "name", false),
                new RemoveCheckConstraintOperation("schema", "table", "name"),
                new RemoveDefaultConstraintOperation("schema", "table", "column", "name"),
                new RemoveForeignKeyOperation("schema", "table", "name"),
                new RemoveIndexOperation("schema", "table", "name"),
                new RemovePrimaryKeyOperation("schema", "table", "name"),
                new RemoveRowGuidColOperation("schema", "table", "name"),
                new RemoveUniqueKeyOperation("schema", "table", "name"),
            };

            // first, make sure we have them all.
            var expectedOps = AppDomain.CurrentDomain.GetAssemblies()
                                .Where(assembly => assembly.GetName().Name == "Rivet")
                                .SelectMany(assembly => assembly.GetTypes())
                                .Where(type => type.IsSubclassOf(typeof(TableObjectOperation)))
                                .Where(type => !type.IsAbstract);

            Assert.That(expectedOps, Is.Not.Empty);
            foreach (var expectedOp in expectedOps)
            {
                var count = tableObjectOps.Where(t => t.GetType() == expectedOp).Count();
                Assert.That(count, Is.Not.EqualTo(0), $"Class {expectedOp.FullName} is missing. Please add an instance of this type to this test.");
            }

            foreach (var op in tableObjectOps)
            {
                var removeTableOp = new RemoveTableOperation("SCHEMA", "TABLE");
                op.Merge(removeTableOp);
                Assert.That(op.Disabled, Is.True, $"{op.GetType().Name} should not be disabled when its table is removed.");
                Assert.That(removeTableOp.Disabled, Is.False);
            }
        }

        [Test]
        public void ShouldDisableRenameOperationAndUpdateTableNameWhenRenamingTable()
        {
            var tableObjectOps = new TableObjectOperation[]
            {
                new AddRowGuidColOperation("schema", "name", "columnName"),
                new AddCheckConstraintOperation("schema", "name", "constraint", "expression", false, false),
                new AddDefaultConstraintOperation("schema", "name", "expression", "column", "constraint", false),
                new AddForeignKeyOperation("schema", "name", new string[0], "referencesschema", "referencestable", new string[0], "key", "ondelete", "onupdate", false, false),
                new AddIndexOperation("schema", "name", new string[0], "index", false, false, new string[0], "where", "on", "filestreamon", new string[0]),
                new AddPrimaryKeyOperation("schema", "name", "key", new string[0], false, new string[0]),
                new AddUniqueKeyOperation("schema", "name", "key", new string[0], false, 0, new string[0], "filegroup"),
                new DisableConstraintOperation("schema", "name", "constraint"),
                new EnableConstraintOperation("schema", "name", "constraint", false),
            };

            // first, make sure we have them all.
            var expectedOps = AppDomain.CurrentDomain.GetAssemblies()
                                .Where(assembly => assembly.GetName().Name == "Rivet")
                                .SelectMany(assembly => assembly.GetTypes())
                                .Where(type => type.IsSubclassOf(typeof(TableObjectOperation)))
                                .Where(type => !type.IsAbstract)
                                .Where(type => !type.Name.StartsWith("Remove", StringComparison.InvariantCultureIgnoreCase));

            Assert.That(expectedOps, Is.Not.Empty);
            foreach (var expectedOp in expectedOps)
            {
                var count = tableObjectOps.Where(t => t.GetType() == expectedOp).Count();
                Assert.That(count, Is.Not.EqualTo(0), $"Class {expectedOp.FullName} is missing. Please add an instance of this type to this test.");
            }

            foreach (var tableObjectOp in tableObjectOps)
            {
                var renameOp = new RenameObjectOperation("SCHEMA", "NAME", "newname");
                tableObjectOp.Merge(renameOp);
                Assert.That(tableObjectOp.Disabled, Is.False);
                Assert.That(renameOp.Disabled, Is.True, $"Merge with rename on {tableObjectOp.GetType().FullName} didn't disable rename operation.");
                Assert.That(tableObjectOp.TableName, Is.EqualTo("newname"), $"Merge with rename on {tableObjectOp.GetType().FullName} didn't change name.");
            }
        }
    }
}
