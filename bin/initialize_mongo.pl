use strict;
use Dancer;
use MongoDB;
use DFUser;
use DFHost;
use Data::Dumper;

# initialize database
my $client     = MongoDB::MongoClient->new(host => 'mongo', port => 27017);
my $db = $client->get_database("dockerforge");
if($ARGV[0] =~ /purge/i){

    map{$db->get_collection($_)->drop} $db->collection_names();
    $db->drop;
}

my $collection = $db->get_collection('DFUsers');
# create index
$collection->ensure_index( { Username => 1 }, {unique => 1});

# main user
my $user = DFUser->load(Username => 'root') || DFUser->new(Username => 'root')->save;


my $collection = $db->get_collection('DFHosts');
$collection->ensure_index( { Hostname => 1 }, {unique => 1});
$collection->ensure_index( { _id_DFUser => 1 } );
DFHost->new(ApiUrl => 'http://localhost', Hostname => 'host01.riyic.com', _id_DFUser => $user->_id)->save;

my $collection = $db->get_collection('DFContainers');
$collection->ensure_index( { Id => 1 }, {unique => 1});
$collection->ensure_index( { _id_DFUser => 1 } );
$collection->ensure_index( { _id_DFImage => 1 } );
$collection->ensure_index( { _id_DFHost => 1 } );


my $collection = $db->get_collection('DFImages');
$collection->ensure_index( { Id => 1 }, {unique => 1});
$collection->ensure_index( { _id_DFUser => 1 } );


my $collection = $db->get_collection('DFJobs');
$collection->ensure_index( { task => 1 });
$collection->ensure_index( { running => 1, done => 1 });
