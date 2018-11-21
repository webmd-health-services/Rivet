using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using Rivet.Operations;
using System.Collections;
using System.Text.RegularExpressions;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRowOperationTestFixture
	{
		private const string SchemaName = "schemaName";
		private const string TableName = "tableName";
		private AddRowOperation _op;

		private static readonly Hashtable NewYork = new Hashtable
		{
			{"City", "New York"},
			{"State", "New York"},
			{"Population", 8336697}
		};

		private static readonly Hashtable LosAngeles = new Hashtable
		{
			{"City", "Los Angeles"},
			{"State", "California"},
			{"Population", 3857799}
		};

		public Hashtable[] ArrayofHashtables = {NewYork, LosAngeles};

		[Test]
		public void ShouldSetPropertiesForAddRow()
		{
			GivenRows(ArrayofHashtables);
			Assert.AreEqual(SchemaName, _op.SchemaName);
			Assert.AreEqual(TableName, _op.TableName);
			Assert.AreEqual(2, _op.Count);
			Assert.AreEqual(NewYork["City"], _op.Column[0]["City"]);
			Assert.AreEqual(LosAngeles["City"], _op.Column[1]["City"]);
			Assert.AreEqual(NewYork["State"], _op.Column[0]["State"]);
			Assert.AreEqual(LosAngeles["State"], _op.Column[1]["State"]);
			Assert.AreEqual(NewYork["Population"], _op.Column[0]["Population"]);
			Assert.AreEqual(LosAngeles["Population"], _op.Column[1]["Population"]);
			Assert.That(_op.IdentityInsert, Is.False);
		}

		[Test]
		public void ShouldWriteQueryForAddRow()
		{
			GivenRows(ArrayofHashtables);
			ThenQueryValuesAre(new[] { "State", "City", "Population" }, new []{ "'New York', 'New York', 8336697", "'California', 'Los Angeles', 3857799" });
		}

		[Test]
		public void ShouldTurnOnIdentityInsert()
		{
			GivenIdentityRows(ArrayofHashtables);
			ThenQueryValuesAre(new[] { "State", "City", "Population" }, new []{ "'New York', 'New York', 8336697", "'California', 'Los Angeles', 3857799" });
		}

		[Test]
		public void ShouldHandleBoolean()
		{
			var cols = new Hashtable
			{
				{"Boolean", true},
			};
			GivenRows(new [] { cols } );
			ThenQueryValuesAre(new[] { "Boolean" }, new [] { "1" });
		}

		[Test]
		public void ShouldHandleNumber()
		{
			var cols = new Hashtable
			{
				{"int", 1},
			};
			GivenRows(new [] { cols } );
			ThenQueryValuesAre(new[] { "int" }, new[] { "1" });
		}

		[Test]
		public void ShouldHandleDateTime()
		{
			var datetime = new DateTime(2013, 10, 17, 18, 18, 00);
			var cols = new Hashtable
			{
				{"datetime", datetime},
			};
			GivenRows(new [] { cols } );
			ThenQueryValuesAre(new[] { "datetime" }, new[] { string.Format("'{0}'", datetime) });
		}

		[Test]
		public void ShouldHandleString()
		{
			var cols = new Hashtable
			{
				{"name", "McDonald's"},
			};
			GivenRows(new [] { cols } );
			ThenQueryValuesAre(new[] { "name" }, new[] { "'McDonald''s'"});
		}

		[Test]
		public void ShouldHandleEmptyString()
		{
			var cols = new Hashtable
			{
				{"name", ""},
			};
			GivenRows(new [] { cols } );
			ThenQueryValuesAre(new[] { "name" }, new[] { "''"});
		}

		[Test]
		public void ShouldHandleTimeSpan()
		{
			var value = new TimeSpan(0, 0, 0);
			var cols = new Hashtable
			{
				{"name", value},
			};
			GivenRows(new [] { cols } );
			ThenQueryValuesAre(new[] { "name" }, new[] { string.Format("'{0}'", value) });
		}

		[Test]
		public void ShouldHandleNull()
		{
			var cols = new Hashtable
			{
				{"name", null }
			};
			GivenRows(new [] { cols } );
			ThenQueryValuesAre(new[] { "name" }, new[] { "null" });
		}

		private void ThenQueryValuesAre(IEnumerable<string> columns, IEnumerable<string> rows)
		{
            var query = _op.ToQuery();
			var queryBuilder = new StringBuilder();
			if (_op.IdentityInsert)
			{
                Assert.That(query, Does.Contain(string.Format("set IDENTITY_INSERT [{0}].[{1}] on{2}", SchemaName, TableName, Environment.NewLine)));
			}

            foreach (var column in columns)
            {
                Assert.That(query, Does.Contain(string.Format("[{0}]", column)));
            }

            foreach (var row in rows)
            {
                Assert.That(query, Does.Match(string.Format(@"\(|\b{0}\b|\)", Regex.Escape(row))));
			}

			if (_op.IdentityInsert)
			{
                Assert.That(query, Does.Contain(string.Format("set IDENTITY_INSERT [{0}].[{1}] off", SchemaName, TableName)));
			}
        }

        private void GivenRows(Hashtable[] rows)
		{
			_op = new AddRowOperation(SchemaName, TableName, rows);
		}

		private void GivenIdentityRows(Hashtable[] rows)
		{
			_op = new AddRowOperation(SchemaName, TableName, rows, true);
		}
	}
}