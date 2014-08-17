#Dump.pl
use strict;
use Dancer;
use MongoDB;
use Data::Dumper;

my $client     = MongoDB::MongoClient->new(host => 'mongo', port => 27017);
print Dumper([$client->database_names]);

my $db = $client->get_database("dockerforge");
print Dumper([$db->collection_names()]);

foreach my $c ($db->collection_names()){

    my $collection = $db->get_collection($c);

    my $cursor = $collection->find();

    print Dumper([$cursor->all])
}
# $db->drop();
#my $database   = $client->get_database( 'foo' );
#my $collection = $database->get_collection( 'bar' );
#my $id         = $collection->insert({ some => 'data' });
#my $data       = $collection->find_one({ _id => $id })
