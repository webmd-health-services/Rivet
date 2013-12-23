using System;

namespace Rivet.Operations
{
	public sealed class RemoveUserDefinedFunctionOperation : ObjectOperation
	{
		public RemoveUserDefinedFunctionOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return
				string.Format(
					"if object_id('{0}.{1}', 'AF') is not null or object_id('{0}.{1}', 'FN') is not null or object_id('{0}.{1}', 'TF') is not null or object_id('{0}.{1}', 'FS') is not null or object_id('{0}.{1}', 'FT') is not null or object_id('{0}.{1}', 'IF') is not null{2}\t{3}",
					SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop function [{0}].[{1}]", SchemaName, Name);
		}
	}
}
