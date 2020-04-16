using System;

namespace Rivet.Operations
{
	public sealed class UpdateExtendedPropertyOperation : ExtendedPropertyOperation
	{
		public UpdateExtendedPropertyOperation(string schemaName, string name, object value) : base(schemaName, name)
		{
			Value = value?.ToString();
		}

		public UpdateExtendedPropertyOperation(string schemaName, string tableViewName, string name, object value, bool forView)
			: base(schemaName, tableViewName, name, forView)
		{
			Value = value?.ToString();
		}

		public UpdateExtendedPropertyOperation(string schemaName, string tableViewName, string columnName, string name, object value, bool forView) 
			: base(schemaName, tableViewName, columnName, name, forView)
		{
			Value = value?.ToString();
		}

		protected override string StoredProcedureName => "sp_updateextendedproperty";

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}
	}
}
