using System;

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
                namespaceClause = string.Format(", @namespace = '{0}'", Namespace);
            }
            return string.Format("declare @result{0} int{1}exec @result{0} = sp_refreshsqlmodule @name = '{2}.{3}'{4}{1}select @result{0}", Guid.NewGuid().ToString("N"), Environment.NewLine, SchemaName, Name, namespaceClause);
        }

        public override string ToIdempotentQuery()
        {
            return ToQuery();
        }
    }
}
