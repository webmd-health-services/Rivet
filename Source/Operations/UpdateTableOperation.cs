using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{

	[ObjectRemovedByOperation(typeof(RemoveTableOperation))]
	public sealed class UpdateTableOperation : ObjectOperation
	{
		public UpdateTableOperation(string schemaName, string name, Column[] addColumns, Column[] updateColumns, string[] removeColumns)
			: base(schemaName, name)
		{
			AddColumns = new List<Column>(addColumns ?? new Column[0]);
			UpdateColumns = new List<Column>(updateColumns ?? new Column[0]);
			RemoveColumns = new List<string>(removeColumns ?? new string[0]);
		}

		public List<Column> AddColumns { get; private set; }

		public List<string> RemoveColumns { get; private set; }

		public List<Column> UpdateColumns { get; private set; }

		private Column FindColumn(string name)
		{
			return AddColumns
				.Concat(UpdateColumns)
				.FirstOrDefault(c => c.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase));
		}

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			// only table object operations that operate on this table are allowed.
			if (operation is TableObjectOperation otherAsTableObjectOp &&
				!ObjectName.Equals(otherAsTableObjectOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase))
				return MergeResult.Stop;

			switch (operation)
			{
				case AddDefaultConstraintOperation otherAsAddDefaultConstraintOp when !otherAsAddDefaultConstraintOp.WithValues:
				{
					var column = FindColumn(otherAsAddDefaultConstraintOp.ColumnName);
					if (column != null)
					{
						column.DefaultExpression = otherAsAddDefaultConstraintOp.Expression;
						column.DefaultConstraintName = otherAsAddDefaultConstraintOp.Name;
						otherAsAddDefaultConstraintOp.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				case AddRowGuidColOperation otherAsAddRowGuidColOp:
				{
					var column = FindColumn(otherAsAddRowGuidColOp.ColumnName);
					if (column != null && column.DataType == DataType.UniqueIdentifier)
					{
						column.RowGuidCol = true;
						otherAsAddRowGuidColOp.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				case RenameColumnOperation otherAsRenameColumnOp:
				{
					var column = FindColumn(otherAsRenameColumnOp.Name);
					if (column != null)
					{
						column.Name = otherAsRenameColumnOp.NewName;
						otherAsRenameColumnOp.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				case RemoveDefaultConstraintOperation otherAsRemoveDefaultConstraintOp:
				{
					var column = FindColumn(otherAsRemoveDefaultConstraintOp.ColumnName);
					if( column != null )
					{
						column.DefaultExpression = null;
						otherAsRemoveDefaultConstraintOp.Disabled = true;
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

				case UpdateTableOperation otherAsUpdateTableOp:
				{
					if (otherAsUpdateTableOp.Disabled)
						return MergeResult.Stop;

					AddColumns.AddRange(otherAsUpdateTableOp.AddColumns);

					foreach (var addColumn in otherAsUpdateTableOp.AddColumns)
					{
						for (var thisIdx = RemoveColumns.Count - 1; thisIdx >= 0; --thisIdx)
						{
							if (addColumn.Name.Equals(RemoveColumns[thisIdx],
								StringComparison.InvariantCultureIgnoreCase))
							{
								RemoveColumns.RemoveAt(thisIdx);
								break;
							}
						}
					}

					foreach( var otherColumn in otherAsUpdateTableOp.UpdateColumns )
					{
						var found = false;
						for (var thisIdx = 0; thisIdx < AddColumns.Count; ++thisIdx)
						{
							var thisColumn = AddColumns[thisIdx];
							if (thisColumn.Name.Equals(otherColumn.Name, StringComparison.InvariantCultureIgnoreCase))
							{
								found = true;
								AddColumns[thisIdx] = otherColumn;
								break;
							}
						}

						for (var thisIdx = 0; thisIdx < UpdateColumns.Count; ++thisIdx)
						{
							var thisColumn = UpdateColumns[thisIdx];
							if (thisColumn.Name.Equals(otherColumn.Name, StringComparison.InvariantCultureIgnoreCase))
							{
								found = true;
								UpdateColumns[thisIdx] = otherColumn;
								break;
							}
						}

						if (!found)
						{
							UpdateColumns.Add(otherColumn);
						}
					}

					foreach (var columnToRemove in otherAsUpdateTableOp.RemoveColumns)
					{
						var found = false;
						for (var thisIdx = AddColumns.Count - 1; thisIdx >= 0; --thisIdx)
						{
							var thisColumn = AddColumns[thisIdx];
							if (thisColumn.Name.Equals(columnToRemove, StringComparison.InvariantCultureIgnoreCase))
							{
								found = true;
								AddColumns.RemoveAt(thisIdx);
								break;
							}
						}

						for (var thisIdx = UpdateColumns.Count - 1; thisIdx >= 0; --thisIdx)
						{
							var thisColumn = UpdateColumns[thisIdx];
							if (thisColumn.Name.Equals(columnToRemove, StringComparison.InvariantCultureIgnoreCase))
							{
								found = true;
								UpdateColumns.RemoveAt(thisIdx);
								break;
							}
						}

						if (!found)
						{
							RemoveColumns.Add(columnToRemove);
						}
					}

					otherAsUpdateTableOp.Disabled = true;

					if (AddColumns.Count == 0 && UpdateColumns.Count == 0 && RemoveColumns.Count == 0)
					{
						Disabled = true;
						return MergeResult.Stop;
					}

					return MergeResult.Continue;
				}
			}

			return MergeResult.Continue;
		}

		public override string ToIdempotentQuery()
		{
			return ToQuery(true);
		}

		public override string ToQuery()
		{
			return ToQuery(false);
		}

		private string ToQuery(bool idempotent)
		{
			var query = new StringBuilder();

			foreach (var column in AddColumns)
			{
				if (query.Length > 0)
				{
					query.AppendLine();
				}
				if (idempotent)
				{
					query.AppendFormat(
						"if not exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{2}'){3}    ",
						SchemaName, Name, column.Name, Environment.NewLine);
				}
				var definition = column.GetColumnDefinition(false);
				query.AppendFormat("alter table [{0}].[{1}] add {2}", SchemaName, Name, definition);
			}

			foreach (var column in UpdateColumns)
			{
				if (query.Length > 0)
				{
					query.AppendLine();
				}

				var definition = column.GetColumnDefinition(false);
				query.AppendFormat("alter table [{0}].[{1}] alter column {2}", SchemaName, Name, definition);
			}

			foreach (var columnName in RemoveColumns)
			{
				if (query.Length > 0)
				{
					query.AppendLine();
				}
				if (idempotent)
				{
					query.AppendFormat("if exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{2}'){3}    ",
						SchemaName, Name, columnName, Environment.NewLine);
				}
				query.AppendFormat("alter table [{0}].[{1}] drop column [{2}]", SchemaName, Name, columnName);
			}

			return query.ToString();
		}
	}

}