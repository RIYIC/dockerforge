package DFJob;

use strict;
use parent qw(DFBase);


has(
    params => {},
    results => {},
    # creation_timestamp => undef,
    start_timestamp => undef,
    termination_timestamp => undef
    running => undef,
    done => undef,
)

sub getPendingJob{
    my ($class,%args) = @_;

    &__collection($class)->find_and_modify(
        query => {running => 0, done => 0},
        sort => {_id => 1},
        update => {running => 1, start_timestamp => time() },
    )

}

#Runner->(DFJob->getPendingJob)->run();