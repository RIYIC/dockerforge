package DFImage;

use strict;
use parent qw(DFBase);

use Eixo::Docker::Api;

has(
    Id => undef, # docker Id
    Name => undef,

    # relations
    _id_DFUser => undef,
);

sub HAS_ONE {

    user => 'DFUser'
}

1;