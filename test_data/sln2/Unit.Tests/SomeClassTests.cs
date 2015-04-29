using NUnit.Framework;
using ProjectName.SomeFolderInProject;

namespace ProjectName2
{
    [TestFixture]
    class SomeClassTests
    {
        [Test]
        public void TestDoSomeWork()
        {
            Assert.That(new SomeClass().DoSomeWork(1, 2), Is.EqualTo(3));
        }

        [Test]
        public void FailingTestDoSomeWork()
        {
            Assert.That(new SomeClass().DoSomeWork(5, 2), Is.EqualTo(4));
        }
    }
}
