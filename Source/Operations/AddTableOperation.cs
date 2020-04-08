using System;
using System.Collections.Generic;
using System.Linq;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveTableOperation))]
	public sealed class AddTableOperation : ObjectOperation
	{
		public AddTableOperation(string schemaName, string name, Column[] columns, bool fileTable, string fileGroup,
			string textImageFileGroup, string fileStreamFileGroup, string[] options)
			: base(schemaName, name)
		{
			Columns = new List<Column>(columns ?? new Column[0]);
			FileTable = fileTable;
			FileGroup = fileGroup;
			TextImageFileGroup = textImageFileGroup;
			FileStreamFileGroup = fileStreamFileGroup;
			Options = new List<string>(options ?? new string[0]);
		}

		public List<Column> Columns { get; private set; }

		public bool FileTable { get; set; }

		public string FileGroup { get; set; }

		public string FileStreamFileGroup { get; set; }

		public List<string> Options { get; private set; }

		public string TextImageFileGroup { get; set; }

		private Column FindColumn(string name)
		{
			return Columns.FirstOrDefault(c => c.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase));
		}

		protected override MergeResult DoMerge(Operation operation)
		{
			if( base.DoMerge(operation) == MergeResult.Stop )
				return MergeResult.Stop;

			// only table object operations that operate on this table are allowed.
			if( operation is TableObjectOperation otherAsTableObjectOp && 
				!ObjectName.Equals(otherAsTableObjectOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase) )
				return MergeResult.Stop;

			switch (operation)
			{
				case UpdateTableOperation updateTableOp:
				{
					if (operation.Disabled)
						return MergeResult.Stop;

					foreach (var column in updateTableOp.AddColumns)
					{
						var found = false;
						for (var idx = 0; idx < Columns.Count; ++idx)
						{
							if (Columns[idx].Name.Equals(column.Name, StringComparison.InvariantCultureIgnoreCase))
							{
								found = true;
								Columns[idx] = column;
								break;
							}
						}

						if (!found)
						{
							Columns.Add(column);
						}
					}

					for ( var idx = 0; idx < Columns.Count; ++idx )
					{
						var originalColumn = Columns[idx];
						var updateColumn = updateTableOp.UpdateColumns.SingleOrDefault(c => c.Name.Equals(originalColumn.Name, StringComparison.InvariantCultureIgnoreCase));
						if( updateColumn != null )
						{
							Columns[idx] = updateColumn;
						}
					}

					foreach( var columnName in updateTableOp.RemoveColumns )
					{
						var index = Columns.FindIndex(c => c.Name.Equals(columnName, StringComparison.InvariantCultureIgnoreCase));
						if( index >= 0 )
						{
							Columns.RemoveAt(index);
						}
					}

					operation.Disabled = true;
					return MergeResult.Continue;
				}

				case RenameColumnOperation renameColumnOp when ObjectName.Equals(renameColumnOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase):
				{
					var column = FindColumn(renameColumnOp.Name);
					if( column != null )
					{
						column.Name = renameColumnOp.NewName;
						renameColumnOp.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				// column default constraints don't handle with values clause (yet)
				case AddDefaultConstraintOperation addDefaultConstraintOp when !addDefaultConstraintOp.WithValues:
				{
					var column = FindColumn(addDefaultConstraintOp.ColumnName);
					if( column != null )
					{
						column.DefaultExpression = addDefaultConstraintOp.Expression;
						operation.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				case RemoveDefaultConstraintOperation removeDefaultConstraint:
				{
					var column = FindColumn(removeDefaultConstraint.ColumnName);
					if (column != null)
					{
						column.DefaultExpression = null;
						removeDefaultConstraint.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				case AddRowGuidColOperation otherAsRowGuidColOp:
				{
					var column = FindColumn(otherAsRowGuidColOp.ColumnName);
					if (column != null && column.DataType == DataType.UniqueIdentifier)
					{
						column.RowGuidCol = true;
						otherAsRowGuidColOp.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				case RemoveRowGuidColOperation otherAsRemoveRowGuidColOp:
				{
					var column = FindColumn(otherAsRemoveRowGuidColOp.ColumnName);
					if (column != null && column.DataType == DataType.UniqueIdentifier)
					{
						column.RowGuidCol = false;
						otherAsRemoveRowGuidColOp.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}
			}

			return MergeResult.Continue;
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'U') is null{Environment.NewLine}\t{ToQuery()}";
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
				foreach (var column in Columns)
				{
					columnDefinitionList.Add(column.GetColumnDefinition(Name, SchemaName, false));
				}
				columnDefinitionClause = string.Join($",{Environment.NewLine}    ", columnDefinitionList.ToArray());
				columnDefinitionClause = string.Format("({0}    {1}{0})", Environment.NewLine, columnDefinitionClause);
			}

			var fileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				fileGroupClause = $"{Environment.NewLine}on {FileGroup}";
			}

			var textImageFileGroupClause = "";
			if (!string.IsNullOrEmpty(TextImageFileGroup))
			{
				textImageFileGroupClause = $"{Environment.NewLine}textimage_on {TextImageFileGroup}";
			}

			var fileStreamFileGroupClause = "";
			if (!string.IsNullOrEmpty(FileStreamFileGroup))
			{
				fileStreamFileGroupClause = $"{Environment.NewLine}filestream_on {FileStreamFileGroup}";
			}

			var optionsClause = "";
			if (Options.Count > 0)
			{
				optionsClause = string.Join(", ", Options.ToArray());
				optionsClause = $"{Environment.NewLine}with ( {optionsClause} )";
			}

			return $"create table [{SchemaName}].[{Name}] {columnDefinitionClause}{fileGroupClause}{textImageFileGroupClause}{fileStreamFileGroupClause}{optionsClause}";
		}
	}
}
