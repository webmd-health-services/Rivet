using System;

namespace Rivet
{
	public class PrecisionScale
	{
		private bool _hasScale;

		public PrecisionScale(int precision)
		{
			Precision = precision;
			_hasScale = false;
		}

		public PrecisionScale(int precision, int scale)
		{
			Precision = precision;
			Scale = scale;
			_hasScale = true;
		}

		public int Precision { get; set; }

		public int Scale { get; set; }

		public override string ToString()
		{
			var scaleClause = "";
			if (_hasScale)
			{
				scaleClause = String.Format(",{0}", Scale);
			}
			return string.Format("({0}{1})", Precision, scaleClause);
		}
	}

	public sealed class CharacterLength : PrecisionScale
	{
		public CharacterLength(int length) : base(length)
		{
			IsMax = false;
		}

		public CharacterLength() : base(0)
		{
			IsMax = true;
		}

		public bool IsMax { get; set; }

		public override string ToString()
		{
			return IsMax ? "(max)" : base.ToString();
		}
	}

	public sealed class XmlPrecisionScale : PrecisionScale
	{
		public XmlPrecisionScale(string xmlSchemaCollection) : base(0)
		{
			Content = true;
			XmlSchemaCollection = xmlSchemaCollection;
		}

		public XmlPrecisionScale(bool isDocument, string xmlSchemaCollection) : base(0)
		{
			Document = isDocument;
			XmlSchemaCollection = xmlSchemaCollection;
		}

		public bool Content { get; set; }
		public bool Document
		{
			get { return !Content; } 
			set { Content = !value; }
		}

		public string XmlSchemaCollection { get; set; }

		public override string ToString()
		{
			var clause = "content";
			if (Document)
			{
				clause = "document";
			}
			return String.Format("({0} {1})", clause, XmlSchemaCollection);
		}
	}
}
