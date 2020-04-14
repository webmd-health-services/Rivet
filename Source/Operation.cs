using Rivet.Operations;
using System;
using System.Collections;
using System.Collections.Generic;

namespace Rivet
{
	public abstract class Operation
	{
		protected Operation()
		{
			CommandTimeout = 30;
			Parameters = new Hashtable();
			ChildOperations = new List<Operation>();
		}

		/// <summary>
		/// The maximum amount of seconds the query should take. Defaults to 30 seconds. If the query takes longer than the timeout, ADO.NET will terminate the query.
		/// </summary>
		public int CommandTimeout { get; set; }

		public bool Disabled { get; internal set; }

		// Any child operations spawned by this operation. These operations are for informational purposes only.
		public IList<Operation> ChildOperations { get; }

		/// <summary>
		/// Any parameters to send with the query.
		/// </summary>
		public Hashtable Parameters { get; }

		/// <summary>
		/// What kind of results to expect from the operation. Default is `NonQuery`, which means no results are expected.
		/// </summary>
		// ReSharper disable once UnusedMember.Global
		public abstract OperationQueryType QueryType { get; }

		private static string GetObjectName(Operation operation)
		{
			switch (operation)
			{
				case ObjectOperation objectOp:
					return objectOp.ObjectName;
				case TableObjectOperation tableObjectOp:
					return tableObjectOp.TableObjectName;
				case AddSchemaOperation schemaOp:
					return schemaOp.Name;
				case RemoveSchemaOperation schemaOp:
					return schemaOp.Name;
				default:
					return null;
			}
		}

		public void Merge(Operation operation)
		{
			if (Disabled)
				return;

			if (operation == null)
				throw new ArgumentNullException(nameof(operation));

			// If this operation is adding an object and the incoming operation is removing it, disable both.
			var thisType = GetType();
			if (thisType.GetCustomAttributes(typeof(ObjectRemovedByOperationAttribute), false) is ObjectRemovedByOperationAttribute[] attrs)
			{
				foreach (var attr in attrs)
				{
					var removalType = attr.RemovedBy;
					if (operation.GetType() != removalType)
					{
						continue;
					}

					var objectName = GetObjectName(this);
					var otherObjectName = GetObjectName(operation);

					if (objectName != null && objectName.Equals(otherObjectName, StringComparison.InvariantCultureIgnoreCase))
					{
						Disabled = operation.Disabled = true;
						return;
					}
				}
			}

			DoMerge(operation);
		}

		protected virtual MergeResult DoMerge(Operation operation)
		{
			return MergeResult.Continue;
		}

		/// <summary>
		/// The query to run for this operation.
		/// </summary>
		/// <returns>The query to run.</returns>
		public abstract string ToQuery();

		/// <summary>
		/// An idempotent query to run for this operation.
		/// </summary>
		/// <returns>An idempotent query to run.</returns>
		public abstract string ToIdempotentQuery();
	}
}
