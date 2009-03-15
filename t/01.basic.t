
use strict;
use warnings;

use Test::More tests => 2;
use Test::Differences;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use_ok('Module::Install::ProvidesClass') or BAIL_OUT($@);

use MockMI;

my $mock = MockMI->new(no_index => {
  directory => [qw/t lib/]
});

$mock->auto_provides_class;

eq_or_diff(
  $mock->_provides,
  { Bar => { file => 'foo.pm' },
    'Bar::Foo' => { file => 'foo.pm' },
    Baz => { file => 'foo.pm' }
  }
);
