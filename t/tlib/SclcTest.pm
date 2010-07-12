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

sub test_IsCeePlusPlus_with_cpp_code {
    my $self = shift;
    my $code = "class MyClass {";
    $self->assert(Sclc::IsCeePlusPlus($code));
}

sub test_IsCeePlusPlus_with_c_code {
    my $self = shift;
    my $code = "x = foo(12);";
    $self->assert(!Sclc::IsCeePlusPlus($code));
}

sub test_IsValidLanguage_with_real_language {
    my $self = shift;
    $self->assert(Sclc::IsValidLanguage("Fortran"));
}

sub test_IsValidLanguage_with_fake_language {
    my $self = shift;
    $self->assert(!Sclc::IsValidLanguage("klingon"));
}

1;