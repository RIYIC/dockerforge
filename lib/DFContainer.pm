package DFContainer;

use strict;
use parent qw(DFBase);

use Eixo::Docker::Api;

has(
    Id => undef, # docker Id
    Name => undef,

    # relations
    _id_DFImage => undef,
    _id_DFUser => undef,
    _id_DFHost => undef,
);


sub HAS_ONE {
    host => 'DFHost',
    image => 'DFImage',
    user => 'DFUser'
}


sub delete {
    my $self = $_[0];

    my $client = Eixo::Docker::Api->new($self->host->api_url);

    my $c = $client->containers->get(id => $self->id);

    $c->destroy;

    $self;

    # o delete deberiao realizar o que chamou a esta clase
}

