using System;

namespace Rivet.Operations
{
	public class RenameOperation : Operation
	{
		public RenameOperation(string schemaName, string name, string newName, string type)
		{
			SchemaName = schemaName;
			Name = name;
			NewName = newName;
		    Type = type;
		}

		public string SchemaName { get; set; }

		public string Name { get; set; }

		public string NewName { get; set; }

        public string Type { get; set; }

		protected virtual string GetObjectName()
		{
			return string.Format("[{0}].[{1}]", SchemaName, Name);
		}

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}') is not null and object_id('{0}.{2}') is null{3}begin{3}\t{4}{3}end", SchemaName, Name, NewName, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("declare @result{0} int{1}exec @result{0} = sp_rename @objname = '{2}', @newname = '{3}', @objtype = '{4}'{1}select @result{0}", Guid.NewGuid().ToString("N"), Environment.NewLine, GetObjectName(), NewName, Type);
		}
	}
}
