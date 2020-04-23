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

            var varSuffix = Path.GetRandomFileName().Replace(".", "");
            var resultVarName = $"@result_{varSuffix}";
            // ReSharper disable once StringLiteralTypo
            return $"declare {resultVarName} int{Environment.NewLine}" +
                   $"exec {resultVarName} = sp_refreshsqlmodule @name = '{SchemaName}.{Name}'{namespaceClause}{Environment.NewLine}" +
                   $"select {resultVarName}";
        }

        public override string ToIdempotentQuery()
        {
            return ToQuery();
        }
    }
}
