using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
    [TestFixture]
    internal sealed class AddRowGuidColOperationTestFixture
    {
        [Test]
        public void ShouldUpateColumnNameIfItIsRenamed()
        {
            var op = new AddRowGuidColOperation("schema", "table", "column");
            var renameOp = new RenameColumnOperation("SCHEMA", "TABLE", "COLUMN", "new column");
            op.Merge(renameOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(renameOp.Disabled, Is.True);
            Assert.That(op.ColumnName, Is.EqualTo("new column"));
        }

        [Test]
        [TestCase("schema2", "table", "column")]
        [TestCase("schema", "table2", "column")]
        [TestCase("schema", "table", "column2")]
        public void ShouldNotUpateColumnNameIfNotSameSchemaTableOrColumn(string schemaName, string tableName, string columnName)
        {
            var op = new AddRowGuidColOperation("schema", "table", "column");
            var renameOp = new RenameColumnOperation(schemaName, tableName, columnName, "new column");
            op.Merge(renameOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(renameOp.Disabled, Is.False);
            Assert.That(op.ColumnName, Is.EqualTo("column"));
        }
    }
}
