namespace Rivet.Operations
{
	public sealed class RenameOperation : Operation
	{
		private enum RenameOperationType
		{
			Table,
			Column,
			Constraint
		}
		
		// Table
		public RenameOperation(string schemaName, string currentName, string newName)
		{
			SchemaName = schemaName;
			CurrentName = currentName;
			NewName = newName;
			OperationType = RenameOperationType.Table;
		}

		//Column
		public RenameOperation(string schemaName, string tableName, string currentName, string newName)
		{
			SchemaName = schemaName;
			TableName = tableName;
			CurrentName = currentName;
			NewName = newName;
			OperationType = RenameOperationType.Column;
		}

		//Constraint
		public RenameOperation(string schemaName, string tableName, string currentName, string newName, ConstraintType constraintType)
		{
			SchemaName = schemaName;
			TableName = tableName;
			CurrentName = currentName;
			NewName = newName;
			ConstraintType = constraintType;
			OperationType = RenameOperationType.Constraint;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string CurrentName { get; private set; }
		public string NewName { get; private set; }
		public ConstraintType ConstraintType { get; private set; }
		private RenameOperationType OperationType { get; set; }

		public override string ToQuery()
		{
			if (OperationType == RenameOperationType.Table)
			{
				return string.Format("declare @valback int; exec @valback = sp_rename '{0}.{1}', '{2}'; select @valback;", SchemaName, CurrentName, NewName);
			}

			if (OperationType == RenameOperationType.Column)
			{
				return string.Format("declare @valback int; exec @valback = sp_rename '{0}.{1}.{2}', '{3}', 'COLUMN'; select @valback;", SchemaName, TableName, CurrentName, NewName);
			}

			if (OperationType == RenameOperationType.Constraint)
			{
				if (ConstraintType == ConstraintType.Index)
				{
					return string.Format("declare @valback int; exec @valback = sp_rename '{0}.{1}.{2}', '{3}', 'INDEX'; select @valback;", SchemaName, TableName, CurrentName, NewName);
				}
				return string.Format("declare @valback int; exec @valback = sp_rename '{0}.{1}', '{2}'; select @valback;", SchemaName, CurrentName, NewName);
			}
			return "";
		}
	}
}
