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
				level1Name = string.Format("'{0}'", TableViewName);
			}

			if (ForView)
			{
				level1Type = "'VIEW'";
				level1Name = string.Format("'{0}'", TableViewName);
			}

			if (ForColumn)
			{
				level2Type = "'COLUMN'";
				level2Name = string.Format("'{0}'", ColumnName);
			}

			return
				string.Format(
					"if not exists (select * from fn_listextendedproperty ('{0}', 'schema', '{1}', {2}, {3}, {4}, {5})){6}\t{7}",
					Name, SchemaName, level1Type, level1Name, level2Type, level2Name, Environment.NewLine, ToQuery());
		}

	}
}
