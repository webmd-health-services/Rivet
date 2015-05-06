using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{
    public sealed class EnableCheckConstraintOperation : TableObjectOperation
    {
        public EnableCheckConstraintOperation(string schemaName, string tableName, string name)
            : base(schemaName, tableName, name) { }

        public override string ToIdempotentQuery()
        {
            throw new NotImplementedException();
        }

        public override string ToQuery()
        {
            return string.Format("alter table [{0}].[{1}] with check check constraint [{2}]",
                SchemaName, TableName, Name);
        }
    }
}
