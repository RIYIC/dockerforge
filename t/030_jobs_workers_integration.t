use test_base;

use_ok(DFUser);
use_ok(DFJob);
use_ok(Worker);

my $u = DFUser->load(UserId => 'test') || DFUser->new(UserId => 'test')->save;

map {$_->remove} $u->jobs;

my $job;

# testeamos a creacion dun job
ok (
    $job = $u->createJob(
        'testJob',
        {testing => 1}
    ),

    'Job created: '.Dumper(DFJob->load(_id => $job->_id))
);

# testeamos o procesado de jobs polos workers

Worker->new(jobClass =>'testJob')->run(threads => 1, shots => 1);

my $job = DFJob->load(_id => $job->_id);

ok(
    $job->done,

    'Job terminated correctly '. Dumper($job)
);

ok(
    $job->remove,

    'Job purged from queue'
    
);


# testear que se executan por orden os traballos
# encolar 3 seguidos e comprobar que van FIFO
my @jobs;
for(1..3){
    push @jobs, $u->createJob(
        'testJob',
        {item => $_}
    );
}


Worker->new(jobClass =>'testJob')->run(threads => 1, shots => 1);

my @sorted_jobs = sort {$a->start_timestamp <=> $b->start_timestamp} $u->jobs(task => 'testJob');

# print Dumper(@sorted_jobs);
ok(
    ($sorted_jobs[0]->params->{item} == 1 and
    $sorted_jobs[1]->params->{item} == 2 and
    $sorted_jobs[2]->params->{item} == 3),

    'jobs executed in order of arrival (FIFO)'
);

done_testing();
