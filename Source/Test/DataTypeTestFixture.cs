using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;

namespace Rivet.Test
{
    [TestFixture]
    class DataTypeTestFixture
    {
        [Test]
        public void ShouldImplementEquals()
        {
            Assert.That(DataType.Xml, Is.EqualTo(DataType.Xml));
        }
    }
}
