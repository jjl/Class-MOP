use strict;
use warnings;

use Test::More;

{
    package Foo;
    use exception;
    
    sub new {
        bless {}, 'Foo';
    }
    
    sub except {
        shift;
        exception->new(@_);
    }
    
}

{
    package Bar;
    use exception;
    
    sub one {
        two(@_);
    }
    
    sub two {
        three(@_);
    }
    
    sub three {
        exception->new(@_);
    }
}

{
    
    my $foo = Foo->new;

    my $f1 = $foo->except(message => 'bar');
    my $f2 = $foo->except();
    my $f3 = $foo->except(foo => {1,2});

    my $b1 = Bar::one(message => 'bar');
    my $b2 = Bar::one();
    my $b3 = Bar::one(foo => {1,2});

################################################## BASIC TESTS ###################

    isa_ok($_,'exception',"type check") for ($f1,$f2,$f3,$b1,$b2,$b3);
    isa_ok($_->stacktrace, 'Devel::StackTrace',"stacktraces are stacktraces") for ($f1,$f2,$f3,$b1,$b2,$b3);
    ok(!ref $_->message,"messages are strings") for ($f1,$f2,$f3,$b1,$b2,$b3);
    is($_->message,'bar', "correct messages") for ($f1,$b1);
    ok(!$_->message,'lack of messages') for ($f2,$f3,$b2,$b3);
    
################################################## STRINGIFICATION TESTS ###################
    
    # Verify number of frames dumped
    is(scalar @{[split(/\n/,$_)]}, 2, "length of foos") for $f1,$f2,$f3;
    is(scalar @{[split(/\n/,$_)]}, 4, "length of bars") for $b1,$b2,$b3;
    
    # Verify initial lines
    like([split(/\n/,$_)]->[0], qr{ at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"error messages contain correct info") for ($f1,$f2,$f3,$b1,$b2,$b3);

    # And the messages of the initial lines
    like([split(/\n/,$_)]->[0], qr{^bar at t/}, "messages of f1,b1") for ($f1,$b1);
    
    # And the lack of messages of the other lines
    like([split(/\n/,$_)]->[0], qr{^ at t/}, "messages of others") for ($f2,$f3,$b2,$b3);

    # And the second lines of foo
    like([split(/\n/,$f1)]->[1], qr{^\tFoo::except\(Foo=HASH\(0x[0-9a-f]+\), 'message', 'bar'\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"f1[1]");
    like([split(/\n/,$f2)]->[1], qr{^\tFoo::except\(Foo=HASH\(0x[0-9a-f]+\)\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"f2[1]");
    like([split(/\n/,$f3)]->[1], qr{^\tFoo::except\(Foo=HASH\(0x[0-9a-f]+\), 'foo', HASH\(0x[0-9a-f]+\)\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"f3[1]");

    # And the second lines of bar
    like([split(/\n/,$b1)]->[1], qr{^\tBar::three\('message', 'bar'\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b1[1]");
    like([split(/\n/,$b2)]->[1], qr{^\tBar::three\(\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b2[1]");
    like([split(/\n/,$b3)]->[1], qr{^\tBar::three\('foo', HASH\(0x[0-9a-f]+\)\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b3[1]");

    # And the third lines of bar
    like([split(/\n/,$b1)]->[2], qr{^\tBar::two\('message', 'bar'\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b1[2]");
    like([split(/\n/,$b2)]->[2], qr{^\tBar::two\(\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b2[2]");
    like([split(/\n/,$b3)]->[2], qr{^\tBar::two\('foo', HASH\(0x[0-9a-f]+\)\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b3[2]");

    # And the fourth lines of bar
    like([split(/\n/,$b1)]->[3], qr{^\tBar::one\('message', 'bar'\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b1[3]");
    like([split(/\n/,$b2)]->[3], qr{^\tBar::one\(\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b2[3]");
    like([split(/\n/,$b3)]->[3], qr{^\tBar::one\('foo', HASH\(0x[0-9a-f]+\)\) called at t/[0-9]+_[a-zA-Z0-9_-]+\.t line [0-9]+$},"b3[3]");
}

done_testing;
