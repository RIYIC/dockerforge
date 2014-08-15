package DFImage;

use strict;
use Eixo::Base::Clase;

use parent qw(DFBase);

has(
    Id => undef, # docker Id
    Name => undef,

    # relations
    _id_DFUser => undef,
);

sub HAS_ONE {

    user => 'DFUser'
}

sub build{
    
}

1;