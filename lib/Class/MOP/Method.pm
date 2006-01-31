
package Class::MOP::Method;

use strict;
use warnings;

use Carp         'confess';
use Scalar::Util 'reftype';

our $VERSION = '0.01';

sub meta { 
    require Class::MOP::Class;
    Class::MOP::Class->initialize($_[0]) 
}

sub wrap { 
    my $class = shift;
    my $code  = shift;
    
    (reftype($code) && reftype($code) eq 'CODE')
        || confess "You must supply a CODE reference to wrap";
    
    bless $code => $class;
}
 
1;

__END__

=pod

=head1 NAME 

Class::MOP::Method - Method Meta Object

=head1 SYNOPSIS

=head1 DESCRIPTION

The Method Protocol is very small, since methods in Perl 5 are just 
subroutines within the particular package. Basically all we do is to 
bless the subroutine and provide some very simple introspection 
methods for it.

=head1 METHODS

=over 4

=item B<wrap (&code)>

=item B<meta>

=back

=head1 AUTHOR

Stevan Little E<gt>stevan@iinteractive.comE<lt>

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut