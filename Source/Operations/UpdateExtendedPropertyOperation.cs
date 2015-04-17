using System;

namespace Rivet.Operations
{
	public sealed class UpdateExtendedPropertyOperation : ExtendedPropertyOperation
	{
		public UpdateExtendedPropertyOperation(string schemaName, string name, object value) : base(schemaName, name)
		{
			Value = (value == null) ? null : value.ToString();
		}

		public UpdateExtendedPropertyOperation(string schemaName, string tableViewName, string name, object value, bool forView)
			: base(schemaName, tableViewName, name, forView)
		{
			Value = (value == null) ? null : value.ToString();
		}

		public UpdateExtendedPropertyOperation(string schemaName, string tableViewName, string columnName, string name, object value, bool forView) 
			: base(schemaName, tableViewName, columnName, name, forView)
		{
			Value = (value == null) ? null : value.ToString();
		}

		public string Value { get; set; }

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}

		public override string ToQuery()
		{
			var propertyValue = (Value == null) ? "null" : String.Format("N'{0}'", Value.Replace("'", "''"));
			var query = string.Format("exec sys.sp_updateextendedproperty @name=N'{0}', @value={1},{3}                                   @level0type=N'SCHEMA', @level0name=N'{2}'", Name, propertyValue, SchemaName, Environment.NewLine);

			if (ForTable)
			{
				query += string.Format(",{1}                                   @level1type=N'TABLE', @level1name='{0}'", TableViewName, Environment.NewLine);
			}

			if (ForView)
			{
				query += string.Format(",{1}                                   @level1type=N'VIEW', @level1name='{0}'", TableViewName, Environment.NewLine);
			}

			if (ForColumn)
			{
				query += string.Format(",{1}                                   @level2type=N'COLUMN', @level2name='{0}'", ColumnName, Environment.NewLine);
			}

			return query;
		}
	}
}
