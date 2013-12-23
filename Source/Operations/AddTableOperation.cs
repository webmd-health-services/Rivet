using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddTableOperation : ObjectOperation
	{
		public AddTableOperation(string schemaName, string name, Column[] columns, bool fileTable, string fileGroup,
		                         string textImageFileGroup, string fileStreamFileGroup, string[] options, string description)
			: base(schemaName, name)
		{
			Columns = new List<Column>(columns ?? new Column[0]);
			FileTable = fileTable;
			FileGroup = fileGroup;
			TextImageFileGroup = textImageFileGroup;
			FileStreamFileGroup = fileStreamFileGroup;
			Options = new List<string>(options ?? new string[0]);
			Description = description;
		}

		public override string ObjectName
		{
			get { return string.Format("{0}.{1}", SchemaName, Name); }
		}

		public List<Column> Columns { get; private set; }
		public bool FileTable { get; private set; }
		public string FileGroup { get; private set; }
		public string TextImageFileGroup { get; private set; }
		public string FileStreamFileGroup { get; private set; }
		public List<string> Options { get; private set; }
		public string Description { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'U') is null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			string columnDefinitionClause;
			if (FileTable)
			{
				columnDefinitionClause = "as FileTable";
			}
			else
			{
				var columnDefinitionList = new List<string>();
				foreach (Column column in Columns)
				{
					columnDefinitionList.Add(column.GetColumnDefinition(Name, SchemaName, false));
				}
				columnDefinitionClause = string.Join(String.Format(",{0}    ", Environment.NewLine), columnDefinitionList.ToArray());
				columnDefinitionClause = string.Format("({0}    {1}{0})", Environment.NewLine, columnDefinitionClause);
			}

			var fileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				fileGroupClause = string.Format("{0}on {1}", Environment.NewLine, FileGroup);
			}

			var textImageFileGroupClause = "";
			if (!string.IsNullOrEmpty(TextImageFileGroup))
			{
				textImageFileGroupClause = string.Format("{0}textimage_on {1}", Environment.NewLine, TextImageFileGroup);
			}

			var fileStreamFileGroupClause = "";
			if (!string.IsNullOrEmpty(FileStreamFileGroup))
			{
				fileStreamFileGroupClause = string.Format("{0}filestream_on {1}", Environment.NewLine, FileStreamFileGroup);
			}

			var optionsClause = "";
			if (Options.Count > 0)
			{
				optionsClause = string.Join(", ", Options.ToArray());
				optionsClause = string.Format("{0}with ( {1} )", Environment.NewLine, optionsClause);
			}

			var query = string.Format("create table [{0}].[{1}] {2}{3}{4}{5}{6}", SchemaName, Name, columnDefinitionClause, fileGroupClause, textImageFileGroupClause, fileStreamFileGroupClause, optionsClause);
			return query;
		}
	}
}
