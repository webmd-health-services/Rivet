using System;

namespace Rivet.Operations
{
    public abstract class RenameTableObjectOperation : RenameOperation
    {
        protected RenameTableObjectOperation(string schemaName, string tableName, string name, string newName, string type)
            : base(schemaName, name, newName, type)
        {
            TableName = tableName;
        }

        public string TableName { get; set; }

        public string TableObjectName => $"{SchemaName}.{TableName}";

        public override string ObjectName => $"{SchemaName}.{TableName}.{Name}";

        protected override MergeResult DoMerge(Operation operation)
        {
            if (base.DoMerge(operation) == MergeResult.Stop)
                return MergeResult.Stop;

            if (operation is RenameTableObjectOperation otherAsRenameTableObjectOp &&
                !TableObjectName.Equals(otherAsRenameTableObjectOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase))
            {
                // It's an object on another table so skip it.
                return MergeResult.Stop;
            }

            if (operation is RenameOperation otherAsRenameOp &&
                TableObjectName.Equals(otherAsRenameOp.ObjectName, StringComparison.InvariantCultureIgnoreCase))

            {
	            otherAsRenameOp.OnDisabled += (sender, args) =>
	            {
		            if (sender is RenameOperation disabledRenameTableOp) 
			            TableName = disabledRenameTableOp.NewName;
	            };
                return MergeResult.Continue;
            }

            return MergeResult.Continue;
        }

        protected override string GetSpRenameObjNameParameter()
        {
            return $"[{SchemaName}].[{TableName}].[{Name}]";
        }

    }
}
