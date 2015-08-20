namespace Rivet.Operations
{
	public abstract class ObjectOperation : Operation
	{
		protected ObjectOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		public string Name { get; protected set; }

		public virtual string ObjectName
		{
			get { return string.Format("{0}.{1}", SchemaName, Name); }
		}

		public string SchemaName { get; set; }
	}
}
