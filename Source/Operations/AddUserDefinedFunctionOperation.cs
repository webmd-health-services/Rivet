using System;

namespace Rivet.Operations
{
	public sealed class AddUserDefinedFunctionOperation : ObjectOperation
	{
		public AddUserDefinedFunctionOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

		public string Definition { get; private set; }

		public override string ToIdempotentQuery()
		{
			return
				string.Format(
					"if object_id('{0}.{1}', 'AF') is null and object_id('{0}.{1}', 'FN') is null and object_id('{0}.{1}', 'TF') is null and object_id('{0}.{1}', 'FS') is null and object_id('{0}.{1}', 'FT') is null and object_id('{0}.{1}', 'IF') is null{2}\texec sp_executesql N'{3}'",
					SchemaName, Name, Environment.NewLine, ToQuery().Replace("'", "''"));
		}

		public override string ToQuery()
		{
			return string.Format("create function [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}