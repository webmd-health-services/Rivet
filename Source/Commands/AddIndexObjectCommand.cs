using System;
using System.Management.Automation;
using Rivet.Operations;

namespace Rivet.Commands
{
	[Cmdlet("Add", "Index")]
	// ReSharper disable once UnusedMember.Global
	public sealed class AddIndexObjectCommand : TableObjectCommand
	{
		[Parameter]
		public string[] ColumnName { get; set; }

		[Parameter]
		public string Name { get; set; }

		[Parameter]
		public string[] Include { get; set; }

		[Parameter(ParameterSetName="Descending")]
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
			if (string.IsNullOrEmpty(Name))
			{
				Name = new IndexName(SchemaName, TableName, ColumnName, Unique).ToString();
				WriteWarning(
					$"Index names will be required in a future version of Rivet. Please add a \"Name\" parameter (with a value of \"{Name}\") to the Add-Index operation for the [{SchemaName}].[{TableName}] table's [{string.Join("], [", ColumnName)}] column(s).");
			}

			var usingDescendingParamSet = ParameterSetName == "Descending";
			if (usingDescendingParamSet && Descending.Length > 0 && Descending.Length != ColumnName.Length)
			{
				throw new Exception(
					"Descending parameter has {0} items. ColumnName parameter has {1} items. There should be the same number of items in each parameter.");
			}

			if (usingDescendingParamSet)
			{
				return new AddIndexOperation(SchemaName, TableName, Name, ColumnName, Descending, Unique, Clustered, Option, Where, On, FileStreamOn, Include);
			}

			return new AddIndexOperation(SchemaName, TableName, Name, ColumnName, Unique, Clustered, Option, Where, On, FileStreamOn, Include);
		}
	}
}
