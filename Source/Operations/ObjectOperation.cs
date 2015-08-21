namespace Rivet.Operations
{
	public abstract class ObjectOperation : Operation
	{
		protected ObjectOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		/// <summary>
		/// The name of the object.
		/// </summary>
		public string Name { get; set; }

		public virtual string ObjectName
		{
			get { return string.Format("{0}.{1}", SchemaName, Name); }
		}

		public string SchemaName { get; set; }
	}
}
