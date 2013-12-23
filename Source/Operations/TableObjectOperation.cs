namespace Rivet.Operations
{
	public abstract class TableObjectOperation : ObjectOperation
	{
		protected TableObjectOperation(string schemaName, string tableName, string name) : base(schemaName, name)
		{
			TableName = tableName;
		}

		public override string ObjectName { get { return string.Format("{0}.{1}.{2}", SchemaName, TableName, Name); } }
		public string TableName { get; private set; }
	}
}
