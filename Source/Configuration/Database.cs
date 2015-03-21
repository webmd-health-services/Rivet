using System.Collections.Generic;
using System.IO;

namespace Rivet.Configuration
{
	public sealed class Database
	{
		public Database(string name, string root, string[] targetDatabaseNames, string migrationsDirectoryName = "Migrations")
		{
			Name = name;
			Root = root;
			TargetDatabaseNames = new List<string>(targetDatabaseNames);
			MigrationsRoot = Path.Combine(Root, migrationsDirectoryName);
		}

		public string MigrationsRoot { get; private set; }
		public string Name { get; private set; }
		public string Root { get; private set; }
		public List<string> TargetDatabaseNames { get; private set; } 
	}
}
