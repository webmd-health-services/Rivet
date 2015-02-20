namespace Rivet.Operations
{
	public sealed class ScriptFileOperation : RawQueryOperation
	{
		public ScriptFileOperation(string path, string query) : base(query)
		{
			Path = path;
		}

		public string Path { get; private set; }
	}
}
