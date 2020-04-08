using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
    [TestFixture]
    internal sealed class ObjectOperationTestFixture
    {
        private sealed class TestObjectOperation : ObjectOperation
        {
            public TestObjectOperation(string schemaName, string name) : base(schemaName, name)
            {
            }

            protected override MergeResult DoMerge(Operation operation)
            {
                BaseMergeResult = base.DoMerge(operation);
                DoMergeCalled = true;
                return BaseMergeResult;
            }

            public bool DoMergeCalled { get; private set; }

            public MergeResult BaseMergeResult { get; private set; }

            public override string ToIdempotentQuery()
            {
                throw new NotImplementedException();
            }

            public override string ToQuery()
            {
                throw new NotImplementedException();
            }
        }

        private sealed class RemoveTestObjectOperation : ObjectOperation
        {
            public RemoveTestObjectOperation(string schemaName, string name) : base(schemaName, name)
            {

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
        [TestCase("schema2", "name")]
        [TestCase("schema", "name2")]
        public void ShouldNotDisableOperationIfRemovalOfDifferentlyNamedObjectMerged(string schemaName, string name)
        {
            var op = new TestObjectOperation("schema", "name");
            var removeOp = new RemoveTestObjectOperation(schemaName, name);
            op.Merge(removeOp);
            Assert.That(op.Disabled, Is.False);
            Assert.That(removeOp.Disabled, Is.False);
        }

        private static ObjectOperation[] GetObjectOperations()
        {

            var ops = new ObjectOperation[]
            {
                new AddDataTypeOperation("schema", "name", "from"),
                new AddStoredProcedureOperation("schema", "name", "definition"),
                new AddSynonymOperation("schema", "name", "targetSchemaName", "targetDatabaseName", "targetObjectName"),
                new AddTableOperation("schema", "name", new Column[0], false, "fileGroup", "textImageFileGroup",
                    "fileStream", new string[0]),
                new AddTriggerOperation("schema", "name", "definition"),
                new AddUserDefinedFunctionOperation("schema", "name", "definition"),
                new AddViewOperation("schema", "name", "definition"),
                new UpdateCodeObjectMetadataOperation("schema", "name", "namespace"),
                new UpdateStoredProcedureOperation("schema", "name", "definition"),
                new UpdateTableOperation("schema", "name", new Column[0], new Column[0], new string[0]),
                new UpdateTriggerOperation("schema", "name", "definition"),
                new UpdateUserDefinedFunctionOperation("schema", "name", "definition"),
                new UpdateViewOperation("schema", "name", "definition"),
            };

            var expectedOps = AppDomain.CurrentDomain.GetAssemblies()
                .Where(assembly => assembly.GetName().Name == "Rivet")
                .SelectMany(assembly => assembly.GetTypes())
                .Where(type => type.IsSubclassOf(typeof(ObjectOperation)))
                .Where(type => !type.IsAbstract)
                .Where(type => !type.Name.StartsWith("Remove", StringComparison.InvariantCultureIgnoreCase));

            Assert.That(expectedOps, Is.Not.Empty);
            foreach (var expectedOp in expectedOps)
            {
                var count = ops.Count(t => t.GetType() == expectedOp);
                Assert.That(count, Is.Not.EqualTo(0),
                    $"Class {expectedOp.FullName} is missing. Please add an instance of this type to this test.");
            }

            return ops;
        }

        [Test]
        public void ShouldDisableRenameOperationAndUpdateObjectNameWhenObjectIsRenamed()
        {
            // first, make sure we have them all.
            foreach (var objectOp in GetObjectOperations())
            {
                //var objectType = (objectOp is AddIndexOperation || objectOp is RemoveIndexOperation) ? "INDEX" : "OBJECT";
                var renameOp = new RenameObjectOperation("SCHEMA", "NAME", "newname");
                objectOp.Merge(renameOp);
                Assert.That(objectOp.Disabled, Is.False);
                Assert.That(renameOp.Disabled, Is.True, $"Merge with rename on {objectOp.GetType().FullName} didn't disable rename operation.");
                Assert.That(objectOp.Name, Is.EqualTo("newname"), $"Merge with rename on {objectOp.GetType().FullName} didn't change name.");
            }
        }

        [Test]
        [TestCase("schema2", "name")]
        [TestCase("schema", "name2")]
        public void ShouldSkipOperationsForOtherObjects(string schemaName, string name)
        {
            foreach (var objectOp in GetObjectOperations())
            {
                var op = new TestObjectOperation(schemaName, name);
                op.Merge(objectOp);
                Assert.That(op.Disabled, Is.False);
                Assert.That(objectOp.Disabled, Is.False);
                Assert.That(op.BaseMergeResult, Is.EqualTo(MergeResult.Stop));
                Assert.That(op.DoMergeCalled, Is.True);
            }
        }

        [Test]
        public void ShouldAllowOperationsForTheSameObjects()
        {
            foreach (var objectOp in GetObjectOperations())
            {
                var op = new TestObjectOperation(objectOp.SchemaName.ToUpperInvariant(), objectOp.Name.ToUpperInvariant());
                op.Merge(objectOp);
                Assert.That(op.Disabled, Is.False);
                Assert.That(objectOp.Disabled, Is.False);
                Assert.That(op.BaseMergeResult, Is.EqualTo(MergeResult.Continue));
                Assert.That(op.DoMergeCalled, Is.True);
            }
        }
    }
}
