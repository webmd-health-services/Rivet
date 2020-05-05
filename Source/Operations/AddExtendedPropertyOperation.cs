using System;

namespace Rivet.Operations
{
	public sealed class AddExtendedPropertyOperation : ExtendedPropertyOperation
	{
		// Schema
		public AddExtendedPropertyOperation(string schemaName, string name, object value) : base(schemaName, name)
		{
			Value = value?.ToString();
		}

		// Table or View
		public AddExtendedPropertyOperation(string schemaName, string tableViewName, string name, object value, bool forView)
			: base(schemaName, tableViewName, name, forView)
		{
			Value = value?.ToString();
		}

		// Column
		public AddExtendedPropertyOperation(string schemaName, string tableViewName, string columnName, string name, object value, bool forView) 
			: base(schemaName, tableViewName, columnName, name, forView)
		{
			Value = value?.ToString();
		}

		protected override string StoredProcedureName => "sp_addextendedproperty";

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

			return $"if not exists (select * from fn_listextendedproperty ('{Name}', 'schema', '{SchemaName}', {level1Type}, {level1Name}, {level2Type}, {level2Name})){Environment.NewLine}" +
				   $"    {ToQuery()}";
		}

	}
}
