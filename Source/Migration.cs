using System.Collections;
using System.Collections.Generic;
using Rivet.Operations;

namespace Rivet
{
	public sealed class Migration
	{
		public Migration(string id, string name, string path, string database)
		{
			ID = id;
			Name = name;
			Path = path;
			Database = database;
			PushOperations = new List<Operation>();
			PopOperations = new List<Operation>();
			FullName = System.IO.Path.GetFileNameWithoutExtension(Path);
		}

		public string FullName { get; private set; }
		public string Database { get; private set; }
		public string ID { get; private set; }
		public string Name { get; private set; }
		public string Path { get; private set; }
		public IList PopOperations { get; private set; }
		public IList PushOperations { get; private set; }
	}
}
