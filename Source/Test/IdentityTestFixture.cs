using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;

namespace Rivet.Test
{
    [TestFixture]
    public sealed class IdentityTestFixture
    {
        [Test]
        public void ShouldCreateDefaultIdentity()
        {
            var identity = new Identity();
            Assert.That(identity.ToString(), Is.EqualTo("identity"));
        }

        [Test]
        public void ShouldCreateIdentityWithCustomSeedAndIncrement()
        {
            var identity = new Identity(101, 103);
            Assert.That(identity.ToString(), Is.EqualTo("identity (101,103)"));
        }

        [Test]
        public void ShouldCreateIdentityThatIsNotForReplication()
        {
            var identity = new Identity(true);
            Assert.That(identity.ToString(), Is.EqualTo("identity not for replication"));
        }

        [Test]
        public void ShouldCreateIdentityThatIsNotForReplicationAndHasCustomSeedAndIncrement()
        {
            var identity = new Identity(105, 107, true);
            Assert.That(identity.ToString(), Is.EqualTo("identity (105,107) not for replication"));
        }


        [Test]
        public void ShouldCreateIdentityThatIsForReplicationAndHasCustomSeedAndIncrement()
        {
            var identity = new Identity(105, 107, false);
            Assert.That(identity.ToString(), Is.EqualTo("identity (105,107)"));
        }

    }
}
