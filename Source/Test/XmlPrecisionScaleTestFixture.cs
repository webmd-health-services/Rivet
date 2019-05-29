using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;

namespace Rivet.Test
{
    [TestFixture]
    public sealed class XmlPrecisionScaleTestFixture
    {
        [Test]
        public void ShouldCreateContentExpression()
        {
            var size = new XmlPrecisionScale("some schema");
            Assert.That(size.ToString(), Is.EqualTo("(content some schema)"));
        }

        [Test]
        public void ShouldCreateDocumentExpression()
        {
            var size = new XmlPrecisionScale(true, "some doc");
            Assert.That(size.ToString(), Is.EqualTo("(document some doc)"));
        }

        [Test]
        public void ShouldCreateContentExpressionWhenIsDocumentIsFalse()
        {
            var size = new XmlPrecisionScale(false, "some other content");
            Assert.That(size.ToString(), Is.EqualTo("(content some other content)"));
        }

        [Test]
        public void ShouldCreateSizeWhenNoSchema()
        {
            var size = new XmlPrecisionScale();
            Assert.That(size.ToString(), Is.Empty);
        }
    }
}
