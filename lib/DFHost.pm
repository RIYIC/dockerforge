package DFHost;

use strict;
use Eixo::Base::Clase;
use parent qw(DFBase);

has(
    ApiUrl => undef,
    Hostname => undef,

    _id_DFUser => undef,
    
);

sub HAS_ONE {
    user => 'DFUser'
}


sub createContainer {

    my ($self, $user, %config) = @_;

    # validar parametros necesarios

    # validar que exista imagen, e sexa publica ou do mesmo usuario que o host
    my $image_obj = DFImage->load($user, image => $config{image});

    # validar recursos disponibles no host

    # se non existe a imaxen no host, descargala
    my $client = Eixo::Docker::Api->new($self->ApiUrl);
    $client->images->create();

    ## crear docker en host
    my $h = $client->containers->create(%config);

    # almacenar en bd
    my $container = DFContainer->new(%$h);
    $container->user($user);
    $container->image($image_obj);
    $container->host($self);

    $container->save();

    $container;
}

sub deleteContainer{
    my ($self, $container) = @_;

    my $client = Eixo::Docker::Api->new($self->ApiUrl);

    my $c = $client->containers->get(Id => $container->Id);

    $c->destroy;

    $container->remove();
}


1;