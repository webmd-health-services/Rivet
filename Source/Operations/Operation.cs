﻿using System.Collections;

namespace Rivet.Operations
{
	public abstract class Operation
	{
		protected Operation()
		{
			Parameters = new Hashtable();
			CommandTimeout = 30;
			RowsAffected = -1;
		}

		/// <summary>
		/// The maximum amount of seconds the query should take. Defaults to 30 seconds. If the query takes longer than the timeout, ADO.NET will terminate the query.
		/// </summary>
		public int CommandTimeout { get; set; }

		/// <summary>
		/// The migration this operation is part of.
		/// </summary>
		public Migration Migration { get; set; }

		/// <summary>
		/// Any parameters to send with the query.
		/// </summary>
		public Hashtable Parameters { get; private set; }

		/// <summary>
		/// What kind of results to expect from the operation. Default is `NonQuery`, which means no results are expected.
		/// </summary>
		public OperationQueryType QueryType { get; set; }

		/// <summary>
		/// The number of rows affected. Set to -1 if no rows affected.
		/// </summary>
		public int RowsAffected { get; set; }

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
