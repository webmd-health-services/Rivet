using System.Collections;
using System.Collections.Generic;

namespace Rivet.Configuration
{
	public sealed class Configuration
	{
		public Configuration(string path, string environment, string sqlServerName, string databasesRoot, int connectionTimeout, int commandTimeout)
		{
			Path = path;
			Environment = environment;
			SqlServerName = sqlServerName;
			DatabasesRoot = databasesRoot;
			ConnectionTimeout = connectionTimeout;
			CommandTimeout = commandTimeout;

			Databases = new List<Database>();
			PluginsRoot = new List<string>();
			TargetDatabases = new Hashtable();
		}

		public int CommandTimeout { get; private set; }
		public int ConnectionTimeout { get; private set; }
		public List<Database> Databases { get; private set; }
		public string DatabasesRoot { get; private set; }
		public string Environment { get; private set; }
		public string Path { get; private set; }
		public List<string> PluginsRoot { get; private set; }
		public string SqlServerName { get; private set; }
		public Hashtable TargetDatabases { get; private set; }
	}
}
