package Worker;

use strict;

my $can_use_threads = eval 'use threads; 1';

use Eixo::Base::Clase;
use parent qw(Eixo::Base::Clase);

my $MAX_PARALLEL_JOBS = 4;

has(
    jobClass => 'undef',
    lap => 0
);

sub run {
    my ($self, %args) = @_;

    my %filters = ($self->jobClass)? (task => $self->jobClass) : ();

    my $forever = !$args{shots};

    # si damos mandado esto nun thread, poderiamos devolver o control do worker, para poder 
    # matalo, ou facer outras tarefas
    while($forever or $self->lap < $args{shots}){

        while(my $job = DFJob->getPendingJob(%filters)){

            $self->execJob($job);
        }

        $self->lap($self->lap + 1);

        sleep(1);
    }
}

sub execJob {
    my ($self, $job) = @_;

    $job->runTask;
}

sub stop {
    
}



