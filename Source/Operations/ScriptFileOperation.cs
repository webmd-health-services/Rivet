namespace Rivet.Operations
{
	public sealed class ScriptFileOperation : RawDdlOperation
	{
		public ScriptFileOperation(string path, string query) : base(query)
		{
			Path = path;
		}

		public string Path { get; set; }
	}
}
