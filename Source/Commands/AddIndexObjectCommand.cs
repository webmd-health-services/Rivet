using System;
using System.Management.Automation;
using Rivet.Operations;

namespace Rivet.Commands
{
	[Cmdlet("Add", "Index")]
	public sealed class AddIndexObjectCommand : TableObjectCommand
	{
		[Parameter]
		public string[] ColumnName { get; set; }

		[Parameter]
		public string Name { get; set; }

		[Parameter]
		public string[] Include { get; set; }

		[Parameter(ParameterSetName = "Descending")]
		public bool[] Descending { get; set; }

		[Parameter]
		public SwitchParameter Unique { get; set; }

		[Parameter]
		public SwitchParameter Clustered { get; set; }

		[Parameter]
		public string[] Option { get; set; }

		[Parameter]
		public string Where { get; set; }

		[Parameter]
		public string On { get; set; }

		[Parameter]
		public string FileStreamOn { get; set; }

		protected override Operation CreateOperation()
		{
			var usingDescendingParamSet = ParameterSetName == "Descending";
			if (usingDescendingParamSet && Descending.Length > 0 && Descending.Length != ColumnName.Length)
			{
				throw new Exception(
					"Descending parameter has {0} items. ColumnName parameter has {1} items. There should be the same number of items in each parameter.");
			}

			var customIndexName = !string.IsNullOrEmpty(Name);
			if (usingDescendingParamSet)
			{
				if (customIndexName)
				{
					return new AddIndexOperation(SchemaName, TableName, ColumnName, Name, Descending, Unique, Clustered, Option, Where, On, FileStreamOn, Include);
				}
				return new AddIndexOperation(SchemaName, TableName, ColumnName, Descending, Unique, Clustered, Option, Where, On, FileStreamOn, Include);
			}

			if (customIndexName)
			{
				return new AddIndexOperation(SchemaName, TableName, ColumnName, Name, Unique, Clustered, Option, Where, On, FileStreamOn, Include);
			}
			return new AddIndexOperation(SchemaName, TableName, ColumnName, Unique, Clustered, Option, Where, On, FileStreamOn, Include);
		}
	}
}
