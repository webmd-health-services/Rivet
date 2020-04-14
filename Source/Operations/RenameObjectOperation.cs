using System;

namespace Rivet.Operations
{
	public class RenameObjectOperation : RenameOperation
	{
		public RenameObjectOperation(string schemaName, string name, string newName) :
			this(schemaName, name, newName, "OBJECT")
		{
		}

		public RenameObjectOperation(string schemaName, string name, string newName, string objectType) :
			base(schemaName, name, newName, objectType)
		{
		}

		public override string ObjectName => $"{SchemaName}.{Name}";

		protected override string GetSpRenameObjNameParameter()
		{
			return $"[{SchemaName}].[{Name}]";
		}
	}
}
