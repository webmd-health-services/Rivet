using System;

namespace Rivet.Operations
{
	public sealed class RemoveExtendedPropertyOperation : ExtendedPropertyOperation
	{
		public RemoveExtendedPropertyOperation(string schemaName, string name) : base(schemaName, name)
		{
		}

		public RemoveExtendedPropertyOperation(string schemaName, string tableViewName, string name, bool forView)
			: base(schemaName, tableViewName, name, forView)
		{
		}

		public RemoveExtendedPropertyOperation(string schemaName, string tableViewName, string columnName, string name, bool forView) 
			: base(schemaName, tableViewName, columnName, name, forView)
		{
		}

		protected override string StoredProcedureName => "sp_dropextendedproperty";

		public override string ToIdempotentQuery()
		{
			var level1Type = "null";
			var level1Name = "null";
			var level2Type = "null";
			var level2Name = "null";

			if (ForTable)
			{
				level1Type = "'TABLE'";
				level1Name = $"'{TableViewName}'";
			}

			if (ForView)
			{
				level1Type = "'VIEW'";
				level1Name = $"'{TableViewName}'";
			}

			if (ForColumn)
			{
				level2Type = "'COLUMN'";
				level2Name = $"'{ColumnName}'";
			}

			return
				$"if exists (select * from fn_listextendedproperty ('{Name}', 'schema', '{SchemaName}', {level1Type}, {level1Name}, {level2Type}, {level2Name})){Environment.NewLine}    {ToQuery()}";
		}
	}
}
