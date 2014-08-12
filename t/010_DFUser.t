use test_base;

use_ok(DFUser);

my ($u, $u2);

ok(
    !DFUser->load(UserId => 'test'),
    'test user not exists');


ok(
    $u = DFUser->new(UserId => 'test')->save, 
    'test user created'
);

ok(
    $u = DFUser->load(UserId => 'test'),

    'test user loaded'
);

ok(
    
    (
        $u->UserId('test2')->save and 
        ($u2 = DFUser->load(_id => $u->_id)) 
        and $u2->UserId eq 'test2'
    ),

    'test user modified'

);

ok(
    ($u->remove and !DFUser->load(UserId => 'test')),

    'test user deleted'
);

done_testing();
