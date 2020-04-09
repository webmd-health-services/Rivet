namespace Rivet.Operations
{
	public abstract class ConstraintOperation : TableObjectOperation
	{

		protected ConstraintOperation(string schemaName, string tableName, string name, ConstraintType constraintType) : 
			base(schemaName, tableName, name)
		{
			ConstraintType = constraintType;
		}

		public ConstraintType ConstraintType { get; private set; }
	}
}
