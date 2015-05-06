using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{
    public sealed class DisableCheckConstraintOperation : TableObjectOperation
    {
        public DisableCheckConstraintOperation(string schemaName, string tableName, string name)
            : base(schemaName, tableName, name) { }

        public override string ToIdempotentQuery()
        {
            throw new NotImplementedException();
            //check state of constraint
        }

        public override string ToQuery()
        {
            return string.Format("alter table [{0}].[{1}] nocheck constraint [{2}]",
                SchemaName, TableName, Name);
        }
    }
}
