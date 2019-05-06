using System;

namespace Rivet
{
    public sealed class XmlPrecisionScale : ColumnSize
    {
        public XmlPrecisionScale() : base(NoSize)
        {
            HasSchema = false;
            Content = false;
        }

        public XmlPrecisionScale(string xmlSchemaCollection) : base(NoSize)
        {
            HasSchema = true;
            Content = true;
            XmlSchemaCollection = xmlSchemaCollection;
        }

        public XmlPrecisionScale(bool isDocument, string xmlSchemaCollection) : base(NoSize)
        {
            HasSchema = true;
            Document = isDocument;
            XmlSchemaCollection = xmlSchemaCollection;
        }

        public bool Content { get; private set; }

        public bool Document
        {
            get { return !Content; } 
            set { Content = !value; }
        }

        public bool HasSchema { get; private set; }

        public string XmlSchemaCollection { get; private set; }

        public override string ToString()
        {
            if (!HasSchema)
            {
                return string.Empty;
            }

            var clause = "content";
            if (Document)
            {
                clause = "document";
            }
            return $"({clause} {XmlSchemaCollection})";
        }
    }
}