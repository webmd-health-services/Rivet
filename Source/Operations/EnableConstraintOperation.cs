using System;

namespace Rivet.Operations
{
    public sealed class EnableCheckConstraintOperation : TableObjectOperation
    {
        public EnableCheckConstraintOperation(string schemaName, string tableName, string name)
            : base(schemaName, tableName, name) { }

        public override string ToIdempotentQuery()
        {
            return String.Format("if objectproperty (object_id('{0}.{1}', 'C'), 'CnstIsDisabled') = 1{2}\t{3}",
                SchemaName, Name, Environment.NewLine, ToQuery());
        }

        public override string ToQuery()
        {
            return string.Format("alter table [{0}].[{1}] with check check constraint [{2}]",
                SchemaName, TableName, Name);
        }
    }
}
