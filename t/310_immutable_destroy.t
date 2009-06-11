use strict;
use warnings;
use Test::More tests => 1;
use Class::MOP;

SKIP: {
    unless (eval { require Moose; 1 }) {
        skip 'test requires moose', 1;
        exit 0;
    }

    eval <<'EOF';
    package FooBar;
    use Moose;

    has 'name' => ( is => 'ro' );

    sub DESTROY { shift->name }

    __PACKAGE__->meta->make_immutable;
EOF

    my $f = FooBar->new( name => 'SUSAN' );

    is( $f->DESTROY, 'SUSAN', 'Did Class::MOP::Class overload DESTROY?' );
}
