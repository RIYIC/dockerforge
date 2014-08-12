package DFHost;

use strict;
use parent qw(DFBase);

has(
    api_url => undef,
    hostname => undef,
    
);


sub createContainer {

    my ($self, $user, %config) = @_;

    # validar parametros necesarios

    # validar que exista imagen, e sexa publica ou do mesmo usuario que o host
    $image_obj = DFImage->load($user, image => $config{image});

    # validar recursos disponibles no host

    # se non existe a imaxen no host, descargala
    my $client = Eixo::Docker::Api->new($self->api_url);
    $cliente->images->create();

    ## crear docker en host
    my $container = $client->containers->create(%config);

    # almacenar en bd
    bless($container, DFContainer);

    $container->user($user_obj);
    $container->image($image_obj);
    $container->host($self);
    $container->save();

    $container;
}

sub deleteContainer{
    my ($self, $container) = @_;

    my $client = Eixo::Docker::Api->new($self->api_url);

    my $c = $client->containers->get(Id => $container->Id);

    $c->destroy;

    $container->remove();
}


1;