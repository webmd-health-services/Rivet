using System;
using System.IO;

namespace Rivet.Operations
{
    public sealed class UpdateCodeObjectMetadataOperation : ObjectOperation
    {
        public UpdateCodeObjectMetadataOperation(string schemaName, string name, string triggerNamespace) 
            : base(schemaName, name)
        {
            Namespace = triggerNamespace;
        }

        public string Namespace { get; set; }

        public override string ToQuery()
        {
            var namespaceClause = "";
            if (!string.IsNullOrEmpty(Namespace))
            {
                namespaceClause = $", @namespace = '{Namespace}'";
            }

            var paramGuid = Path.GetRandomFileName().Remove(8, 1);
            paramGuid = $"_{paramGuid}";
            return $"declare @result{paramGuid} int{Environment.NewLine}exec @result{paramGuid} = sp_refreshsqlmodule @name = '{SchemaName}.{Name}'{namespaceClause}{Environment.NewLine}select @result{paramGuid}";
        }

        public override string ToIdempotentQuery()
        {
            return ToQuery();
        }
    }
}
