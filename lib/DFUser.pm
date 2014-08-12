package DFUser;

use strict;
use Eixo::Base::Clase;
use parent qw(DFBase);

has(
    UserId => undef,    
);


sub HAS_MANY {

    hosts => 'DFHost',
    images => 'DFImage',
    jobs => 'DFJobs',
    containers => 'DFContainers',
}