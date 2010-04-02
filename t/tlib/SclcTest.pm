# See http://search.cpan.org/dist/Test-Unit-Lite/lib/Test/Unit/Lite.pm
package SclcTest;

use strict;
use warnings;

use Sclc;

use base 'Test::Unit::TestCase';

sub test_success {
  my $self = shift;
  $self->assert(1);
}

1;