namespace Rivet.Operations
{
	public sealed class RenameOperation : Operation
	{
		private enum ObjectType
		{
			Table,
			Column,
			Database,
			Index,
			Object,
			Statistics,
			Userdatatype
		}

		public RenameOperation(string schemaName, string currentName, string newName)
		{
			SchemaName = schemaName;
			CurrentName = currentName;
			NewName = newName;
			Type = ObjectType.Table;
		}

		public string SchemaName { get; private set; }
		public string CurrentName { get; private set; }
		public string NewName { get; private set; }
		private ObjectType Type { get; set; }

		public override string ToQuery()
		{
			if (Type == ObjectType.Table)
			{
				return string.Format("declare @valback int; exec @valback = sp_rename '{0}.{1}', '{2}'; select @valback;", SchemaName, CurrentName, NewName);
			}

			return "";
		}
	}
}
