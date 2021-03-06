function test_suite = test_packageName
initTestSuite;

function test_happyCase
suite = TestSuite.fromPackageName('xunit.mocktests');
assertEqual(numel(suite.TestComponents), 3);

assertEqual(numel(suite.TestComponents{1}.TestComponents), 2);
assertEqual(suite.TestComponents{1}.Name, 'xunit.mocktests.A');

assertEqual(numel(suite.TestComponents{2}.TestComponents), 1);
assertEqual(suite.TestComponents{2}.Name, 'xunit.mocktests.FooTest');

assertEqual(numel(suite.TestComponents{3}.TestComponents), 1);
assertEqual(suite.TestComponents{3}.Name, 'xunit.mocktests.test_this');

function test_badPackageName
assertExceptionThrown(@() TestSuite.fromPackageName('bogus'), ...
    'xunit:fromPackageName:invalidName');

