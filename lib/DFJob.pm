package DFJob;

use strict;
use Eixo::Base::Clase;
use parent qw(DFBase);


has(
    task => '',
    params => {},
    results => {},
    creation_timestamp => 0,
    start_timestamp => 0,
    termination_timestamp => 0,
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

#
# si as tareas as montamos como clases externas
#

# sub runTask{
#     my $self = $_[0];

#     my $task_class = 'Task::'.$self->task;
#     my $results = {};

#     eval{
#         require $task_class.'.pm'
#     };
#     if($@){

#         $results = {error => "Task $task_class not exists"};
#     }
#     else{
#         $results = $task_class->new(params => $self->params)->run;
#     }

#     $self->results($results);
#     $self->termination_timestamp(time());
#     $self->done(1);
#     $self->save;
# }


#
# Si as tareas son metodos de DFUser
#

sub runTask {
    my $self = $_[0];

    my $method = $self->task;

    my $res = {};

    if($self->user->can($method)){
        $res = $self->user->$method(%{$self->params});
    }
    else{
        $res->{error} = 'Task '. $self->task. ' not exists';
    }

    $self->results($res);
    $self->termination_timestamp(time());
    $self->done(1);
    $self->save;


}

1;