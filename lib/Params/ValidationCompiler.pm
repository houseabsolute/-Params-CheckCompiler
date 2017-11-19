package Params::ValidationCompiler;

use strict;
use warnings;

our $VERSION = '0.25';

use Params::ValidationCompiler::Compiler;

use Exporter qw( import );

our @EXPORT_OK = qw( compile source_for validation_for );

sub validation_for {
    return Params::ValidationCompiler::Compiler->new(@_)->subref;
}

## no critic (TestingAndDebugging::ProhibitNoWarnings)
no warnings 'once';
*compile = \&validation_for;
## use critic

sub source_for {
    return Params::ValidationCompiler::Compiler->new(@_)->source;
}

1;

# ABSTRACT: Build an optimized subroutine parameter validator once, use it forever

__END__

=pod

=for Pod::Coverage compile

=head1 SYNOPSIS

    use Types::Standard qw( Int Str );
    use Params::ValidationCompiler qw( validation_for );

    {
        my $validator = validation_for(
            params => {
                foo => { type => Int },
                bar => {
                    type     => Str,
                    optional => 1,
                },
                baz => {
                    type    => Int,
                    default => 42,
                },
            },
        );

        sub foo {
            my %args = $validator->(@_);
        }
    }

    {
        my $validator = validation_for(
            params => [
                { type => Int },
                {
                    type     => Str,
                    optional => 1,
                },
            ],
        );

        sub bar {
            my ( $int, $str ) = $validator->(@_);
        }
    }

    {
        my $validator = validation_for(
            params => [
                foo => { type => Int },
                bar => {
                    type     => Str,
                    optional => 1,
                },
            ],
            named_to_list => 1,
        );

        sub baz {
            my ( $foo, $bar ) = $validator->(@_);
        }
    }

=head1 DESCRIPTION

This module creates a customized, highly efficient parameter checking
subroutine. It can handle named or positional parameters, and can return the
parameters as key/value pairs or a list of values.

In addition to type checks, it also supports parameter defaults, optional
parameters, and extra "slurpy" parameters.

=head1 EXPORTS

This module has two options exports, C<validation_for> and C<source_for>. Both
of these subs accept the same options:

=over 4

=item * params

An arrayref or hashref containing a parameter specification.

If you pass a hashref then the generated validator sub will expect named
parameters. The C<params> value should be a hashref where the parameter names
are keys and the specs are the values.

If you pass an arrayref and C<named_to_list> is false, the validator will
expect positional params. Each element of the C<params> arrayref should be a
parameter spec.

If you pass an arrayref and C<named_to_list> is true, the validator will
expect named params, but will return a list of values. In this case the
arrayref should contain a I<list> of key/value pairs, where parameter names
are the keys and the specs are the values.

Each spec can contain either a boolean or hashref. If the spec is a boolean,
this indicates required (true) or optional (false).

The spec hashref accepts the following keys:

=over 8

=item * type

A type object. This can be a L<Moose> type (from L<Moose> or
L<MooseX::Types>), a L<Type::Tiny> type, or a L<Specio> type.

If the type has coercions, those will always be used.

=item * default

This can either be a simple (non-reference) scalar or a subroutine
reference. The sub ref will be called without any arguments (for now).

=item * optional

A boolean indicating whether or not the parameter is optional. By default,
parameters are required unless you provide a default.

=back

=item * slurpy

If this is a simple true value, then the generated subroutine accepts
additional arguments not specified in C<params>. By default, extra arguments
cause an exception.

You can also pass a type constraint here, in which case all extra arguments
must be values of the specified type.

=item * named_to_list

If this is true, the generated subroutine will expect a list of key-value
pairs or a hashref and it will return a list containing only values. The
C<params> you pass must be a arrayref of key-value pairs. The order of these
pairs determines the order in which values are returned.

You cannot combine C<slurpy> with C<named_to_list> as there is no way to know
how to order the extra return values.

=back

=head2 validation_for(...)

This returns a subroutine that implements the specific parameter
checking. This subroutine expects to be given the parameters to validate in
C<@_>. If all the parameters are valid, it will return the validated
parameters (with defaults as appropriate), either as a list of key-value pairs
or as a list of just values. If any of the parameters are invalid it will
throw an exception.

For validators expected named params, the generated subroutine accepts either
a list of key-value pairs or a single hashref. Otherwise the validator expects
a list of values.

For now, you must shift off the invocant yourself.

This subroutine accepts the following additional parameters:

=over 4

=item * name

If this is given, then the generated subroutine will be named using
L<Sub::Util>. This is strongly recommended as it makes it possible to
distinguish different check subroutines when profiling or in stack traces.

Note that you must install L<Sub::Util> yourself separately, as it is not
required by this distribution, in order to avoid requiring a compiler.

=item * name_is_optional

If this is true, then the name is ignored when C<Sub::Util> is not
installed. If this is false, then passing a name when L<Sub::Util> cannot be
loaded causes an exception.

This is useful for CPAN modules where you want to set a name if you can, but
you do not want to add a prerequisite on L<Sub::Util>.

=back

=head2 source_for(...)

This returns a two element list. The first is a string containing the source
code for the generated sub. The second is a hashref of "environment" variables
to be used when generating the subroutine. These are the arguments that are
passed to L<Eval::Closure>.
