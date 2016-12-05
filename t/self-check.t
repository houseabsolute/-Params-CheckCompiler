## no critic (Moose::RequireCleanNamespace)
use strict;
use warnings;

use Test2::Bundle::Extended;
use Test2::Plugin::NoWarnings;

use Params::ValidationCompiler qw( validation_for );

like(
    dies { validation_for() },
    qr/\QYou must provide a "params" parameter when creating a parameter validator\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called without parameters'
);

like(
    dies { validation_for( params => 42 ) },
    qr/\QThe "params" parameter when creating a parameter validator must be a hashref or arrayref, you passed a scalar\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with params as a scalar'
);

like(
    dies { validation_for( params => undef ) },
    qr/\QThe "params" parameter when creating a parameter validator must be a hashref or arrayref, you passed an undef\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called params as an undef'
);

like(
    dies { validation_for( params => \42 ) },
    qr/\QThe "params" parameter when creating a parameter validator must be a hashref or arrayref, you passed a scalarref\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called params as a scalarref'
);

like(
    dies { validation_for( params => { a => {} }, foo => 1, bar => 2 ) },
    qr/\QYou passed unknown parameters when creating a parameter validator: [bar foo]\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with extra unknown parameters'
);

like(
    dies { validation_for( params => { a => {} }, name => undef, ) },
    qr/\QThe "name" parameter when creating a parameter validator must be a scalar, you passed an undef\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with name as an undef'
);

like(
    dies { validation_for( params => { a => {} }, name => [], ) },
    qr/\QThe "name" parameter when creating a parameter validator must be a scalar, you passed a arrayref\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with name as an arrayref'
);

like(
    dies {
        validation_for(
            params        => [ a => 1 ],
            named_to_list => 1,
            slurpy        => 1,
        );
    },
    qr/\QYou cannot use "named_to_list" and "slurpy" together\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with named_to_list and slurpy'
);

like(
    dies {
        validation_for(
            params        => [ a => { isa => 1, typo => 2 } ],
            named_to_list => 1,
        );
    },
    qr/\QSpecification contains unknown keys: [isa typo]\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with named_to_list and an invalid spec keys'
);

like(
    dies {
        validation_for(
            params => [ { isa => 1, } ],
        );
    },
    qr/\QSpecification contains unknown keys: [isa]\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with an arrayref params and an invalid spec keys'
);

like(
    dies {
        validation_for(
            params => { a => { isa => 1, typo => 2 } },
        );
    },
    qr/\QSpecification contains unknown keys: [isa typo]\E.+at t.self-check\.t line \d+/,
    'got expected error message when validation_for is called with an hashref params and an invalid spec keys'
);

done_testing();
