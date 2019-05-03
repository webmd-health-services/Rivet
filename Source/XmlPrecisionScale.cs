using System;

namespace Rivet
{
    public sealed class XmlPrecisionScale : ColumnSize
    {
        public XmlPrecisionScale(string xmlSchemaCollection) : base(NoSize)
        {
            Content = true;
            XmlSchemaCollection = xmlSchemaCollection;
        }

        public XmlPrecisionScale(bool isDocument, string xmlSchemaCollection) : base(NoSize)
        {
            Document = isDocument;
            XmlSchemaCollection = xmlSchemaCollection;
        }

        public bool Content { get; private set; }

        public bool Document
        {
            get { return !Content; } 
            set { Content = !value; }
        }

        public string XmlSchemaCollection { get; private set; }

        public override string ToString()
        {
            var clause = "content";
            if (Document)
            {
                clause = "document";
            }
            return $"({clause} {XmlSchemaCollection})";
        }
    }
}