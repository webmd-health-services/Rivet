using System.IO;

namespace Rivet.Configuration
{
	public sealed class Database
	{
		public Database(string name, string root, string migrationsDirectoryName = "Migrations")
		{
			Name = name;
			Root = root;
			MigrationsRoot = Path.Combine(Root, migrationsDirectoryName);
		}

		public string MigrationsRoot { get; private set; }
		public string Name { get; private set; }
		public string Root { get; private set; }
	}
}
