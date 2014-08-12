use MongoDB;
use Data::Dumper;

my $client     = MongoDB::MongoClient->new(host => 'mongo', port => 27017);
print Dumper([$client->database_names]);

my $db = $client->get_database("foo");
print Dumper([$db->collection_names()]);
my $collection = $db->get_collection('bar');
my $cursor = $collection->find();

while(my $o = $cursor->next()){
	print Dumper($o);
}
$db->drop();
#my $database   = $client->get_database( 'foo' );
#my $collection = $database->get_collection( 'bar' );
#my $id         = $collection->insert({ some => 'data' });
#my $data       = $collection->find_one({ _id => $id })
