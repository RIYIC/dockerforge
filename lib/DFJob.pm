package DFJob;

use strict;
use Eixo::Base::Clase;
use parent qw(DFBase);


has(
    task => '',
    params => {},
    results => {},
    creation_timestamp => undef,
    start_timestamp => undef,
    termination_timestamp => undef,
    running => 0,
    done => 0,

    _id_DFUser => undef,
);

sub HAS_ONE {
    user => 'DFUser'
}

sub getPendingJob{
    my ($class,%args) = @_;

    my $doc = &DFBase::__collection($class)->find_and_modify({
        query => {running => 0, done => 0, %args},
        sort => {_id => 1},
        update => {'$set' => {running => 1, start_timestamp => time()}},
        new => 1,
    });

    ($doc)? $class->new(%$doc) : undef;

}

1;