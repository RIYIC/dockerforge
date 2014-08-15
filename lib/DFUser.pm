package DFUser;

use strict;
use Eixo::Base::Clase;
use parent qw(DFBase);
use DFHost;
use DFImage;
use DFJob;

has(
    UserId => undef,    
);


sub HAS_MANY {

    hosts => 'DFHost',
    images => 'DFImage',
    jobs => 'DFJob',
    containers => 'DFContainer',
}

# Obligar a que todos os comandos que chegan pola api pasen polo user permite:
# - que mediante a api so se acceda a aquelas entidades que ten accesibles (relacion) o usuario
# - e moi facil introducir un sistema de permisos para controlar os comandos que pode lanzar un usuario, 



sub remove {
    my $self = $_[0];

    # borrar hosts

    # borrar containers

    # borrar images

    $self->SUPER::remove();
}



sub createHost{

    my ($self,%args) = @_;

    # testear conexion ca API de docker

    DFHost->new(%args,_id_DFUser => $self->_id)->save;
}


sub createJob {
    my ($self, $task, $params)  = @_;

    DFJob->new(
        task => $task, 
        params => $params,
        creation_timestamp => time(),
        _id_DFUser => $self->_id
    )->save;
}

sub testJob {sleep(int(rand(10)))}
