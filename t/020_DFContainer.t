use test_base;

use_ok(DFContainer);


my $container = DFContainer->load(user => 'user01', name => 'midocker');
my $container = DFContainer->load(_id => 'mongoid');
my $container = DFContainer->load(user => 'user01', Id => 'container_id');

$container->start
$container->stop
$container->restart
$container->move($host2);
$container->delete();

my $anfitrion = DFHost->load(_id => $container->_id_host);
#or
my $anfitrion = $container->host;

my $containers = DFContainer->find({})
while(my $c = $containers->next){

}

# esto sempre vai a crear un novo container
DFContainer->create(image => 'aa', name => 'midocker', host => 'mi_host');

DFHost->load(user => 'mi_user', hostname => 'mihost')->createContainer(image => 'imageX');

# se queremos arrancar un m