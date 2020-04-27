using System;

namespace Rivet.Operations
{
	public class RenameDataTypeOperation : RenameOperation
	{
		// ReSharper disable once StringLiteralTypo
		public RenameDataTypeOperation(string schemaName, string name, string newName) : base(schemaName, name, newName, "USERDATATYPE")
		{
		}

		public override string ObjectName => $"{SchemaName}.{Name}";

		protected override string GetSpRenameObjNameParameter()
		{
			return $"[{SchemaName}].[{Name}]";
		}

		public override string ToIdempotentQuery()
		{
			return
				$"if exists(select * from sys.types where name='{Name}' and schema_id=schema_id('{SchemaName}')) and{Environment.NewLine}" +
				$"   not exists(select * from sys.types where name='{NewName}' and schema_id=schema_id('{SchemaName}')){Environment.NewLine}" +
				$"begin{Environment.NewLine}" +
				$"    {ToIndentedQuery()}{Environment.NewLine}" +
				"end";
		}
	}
}
