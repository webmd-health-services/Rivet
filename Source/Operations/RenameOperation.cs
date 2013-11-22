using System;

namespace Rivet.Operations
{
	public class RenameOperation : Operation
	{
		public RenameOperation(string schemaName, string name, string newName)
		{
			SchemaName = schemaName;
			Name = name;
			NewName = newName;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }
		public string NewName { get; private set; }

		protected virtual string GetRenameArguments()
		{
			return string.Format("'{0}.{1}', '{2}', 'OBJECT'", SchemaName, Name, NewName);
		}

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}') is not null and object_id('{0}.{2}') is null{3}\t{4}", SchemaName, Name, NewName, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("declare @result{0} int{1}exec @result{0} = sp_rename {2}{1}select @result{0}", Guid.NewGuid().ToString("N"), Environment.NewLine, GetRenameArguments());
		}
	}
}
