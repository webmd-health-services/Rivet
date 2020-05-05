using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
    [TestFixture]
    internal sealed class UpdateCodeObjectMetadataOperationTestFixture
    {
        [Test]
        public void ShouldGenerateValidRandomResultVariable()
        {
            var op = new UpdateCodeObjectMetadataOperation("schema", "name", null);
            var query = op.ToQuery();
            Assert.That(query, Is.Not.Null);
            Console.WriteLine(query);
            Assert.That(query, Does.Match(@"declare\ @result_[A-Za-z0-9]{11}\b"));
            Assert.That(query, Does.Match(@"exec\ @result_[A-Za-z0-9]{11}\b"));
            Assert.That(query, Does.Match(@"select\ @result_[A-Za-z0-9]{11}\b"));
        }
    }
}
