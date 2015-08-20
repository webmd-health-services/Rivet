using System;

namespace Rivet.Operations
{
    public sealed class EnableForeignKeyOperation : TableObjectOperation
    {
        public EnableForeignKeyOperation(string schemaName, string tableName, string constraintName)
            : base(schemaName, tableName, constraintName) { }

        public override string ToIdempotentQuery()
        {
            return String.Format("if objectproperty (object_id('{0}.{1}', 'F'), 'CnstIsDisabled') = 1{2}\t{3}",
                SchemaName, Name, Environment.NewLine, ToQuery());
        }

        public override string ToQuery()
        {
            return string.Format("alter table [{0}].[{1}] with check check constraint [{2}]",
                SchemaName, TableName, Name);
        }
    }
}
