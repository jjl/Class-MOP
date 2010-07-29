package exception;

use strict;
use warnings;

use overload '""' => \&to_string;

use Devel::StackTrace;

# use Moose; ## Haha, if only.

##### ACCESSORS #####
sub message { shift->{message}; }
sub stacktrace { shift->{stacktrace}; }

# Builder for stacktrace
sub _build_stacktrace {
    shift->{stacktrace} = Devel::StackTrace->new(ignore_class => __PACKAGE__);
}

# Stringification
sub to_string {
    my ($self) = @_;
    my $first = 1;
    my @lines;
    while (my $frame = $self->{stacktrace}->next_frame) {
        if ($first) {
            $first = 0;
            # message at foo.pl line 1
            push @lines, sprintf("%s at %s line %s", $self->message, $frame->filename, $frame->line);
        } else {
            my @args = map { ref $_ ? "$_" : "'$_'" } $frame->args;
            # main::foo called at foo.pl line 1
            push @lines, sprintf("\t%s(%s) called at %s line %s", $frame->subroutine, join(", ", @args), $frame->filename, $frame->line);
        }
    }
    join("\n", @lines);
}

# Constructor
sub new {
    my ($class, %kwargs) = @_;
    $class = ref $class if ref $class; # Also take another exception object, if we must.
    my $message = $kwargs{message} || ''; # Default to no error message
    
    # Construction
    my $self = bless {message => $message}, $class;
    $self->_build_stacktrace;
    
    $self;
}

1;
__END__