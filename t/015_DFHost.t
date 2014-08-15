use test_base;

use_ok(DFHost);
use_ok(DFUser);

my $u = DFUser->load(UserId => 'test') || DFUser->new(UserId => 'test')->save;
my $host ;

map {$_->remove} ($u->hosts);

ok(
    ($u->createHost(
        ApiUrl=>'http://test.com:4243',
        Hostname => 'test.com') 
    and 
    $host = ($u->hosts(hostname => 'test.com'))[0]),

    "Host registered "
);

ok(

    (
        $host->ApiUrl('http://123.com')->save
        and $host = ($u->hosts(hostname => 'test.com'))[0]
        and $host->ApiUrl eq 'http://123.com'
    ),

    'Host updated'

);

ok(
    ($host->remove() and
    scalar($u->hosts(hostname => 'test.com')) == 0),

    'Host deleted'
);

done_testing();
