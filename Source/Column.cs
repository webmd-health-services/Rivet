namespace Rivet
{
	public sealed class Column
	{
		public Column(string name, DataType dataType)
		{
			Name = name;
			DataType = dataType;
		}

		public DataType DataType { get; private set; }
		public string Name { get; private set; }
	}
}
