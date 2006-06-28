#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 80;
use Test::Exception;

BEGIN {
    use_ok('Class::MOP');
    use_ok('Class::MOP::Class::Immutable');    
}

{
    package Foo;
    
    use strict;
    use warnings;
    use metaclass;
    
    __PACKAGE__->meta->add_attribute('bar');
    
    package Bar;
    
    use strict;
    use warnings;
    use metaclass;
    
    __PACKAGE__->meta->superclasses('Foo');

    __PACKAGE__->meta->add_attribute('baz');    
    
    package Baz;
    
    use strict;
    use warnings;
    use metaclass;
    
    __PACKAGE__->meta->superclasses('Bar');

    __PACKAGE__->meta->add_attribute('bah');    
}

{
    my $meta = Foo->meta;
    is($meta->name, 'Foo', '... checking the Foo metaclass');
    
    ok($meta->is_mutable, '... our class is mutable');
    ok(!$meta->is_immutable, '... our class is not immutable');    

    lives_ok {
        $meta->make_immutable();
    } '... changed Foo to be immutable';
    
    ok(!$meta->make_immutable, '... make immutable now returns nothing');
    
    ok(!$meta->is_mutable, '... our class is no longer mutable');
    ok($meta->is_immutable, '... our class is now immutable');    

    isa_ok($meta, 'Class::MOP::Class::Immutable');
    isa_ok($meta, 'Class::MOP::Class');

    dies_ok { $meta->reinitialize() } '... exception thrown as expected';
    
    dies_ok { $meta->add_method()    } '... exception thrown as expected';
    dies_ok { $meta->alias_method()  } '... exception thrown as expected';
    dies_ok { $meta->remove_method() } '... exception thrown as expected';
    
    dies_ok { $meta->add_attribute()    } '... exception thrown as expected';
    dies_ok { $meta->remove_attribute() } '... exception thrown as expected';
                        
    dies_ok { $meta->add_package_variable()    } '... exception thrown as expected';
    dies_ok { $meta->remove_package_variable() } '... exception thrown as expected';

    my @supers;
    lives_ok {
        @supers = $meta->superclasses;
    } '... got the superclasses okay';

    dies_ok { $meta->superclasses([ 'UNIVERSAL' ]) } '... but could not set the superclasses okay';
    
    my $meta_instance;
    lives_ok {
        $meta_instance = $meta->get_meta_instance;
    } '... got the meta instance okay';
    isa_ok($meta_instance, 'Class::MOP::Instance');
    is($meta_instance, $meta->get_meta_instance, '... and we know it is cached');
    
    my @cpl;
    lives_ok {
        @cpl = $meta->class_precedence_list;
    } '... got the class precedence list okay';    
    is_deeply(
    \@cpl,
    [ 'Foo' ],
    '... we just have ourselves in the class precedence list');
    
    my @attributes;
    lives_ok {
        @attributes = $meta->compute_all_applicable_attributes;
    } '... got the attribute list okay';
    is_deeply(
    \@attributes,
    [ $meta->get_attribute('bar') ],
    '... got the right list of attributes');
}

{
    my $meta = Bar->meta;
    is($meta->name, 'Bar', '... checking the Bar metaclass');    
    
    ok($meta->is_mutable, '... our class is mutable');
    ok(!$meta->is_immutable, '... our class is not immutable');    

    lives_ok {
        $meta->make_immutable();
    } '... changed Bar to be immutable';
    
    ok(!$meta->make_immutable, '... make immutable now returns nothing');
    
    ok(!$meta->is_mutable, '... our class is no longer mutable');
    ok($meta->is_immutable, '... our class is now immutable');    

    isa_ok($meta, 'Class::MOP::Class::Immutable');
    isa_ok($meta, 'Class::MOP::Class');

    dies_ok { $meta->reinitialize() } '... exception thrown as expected';
    
    dies_ok { $meta->add_method()    } '... exception thrown as expected';
    dies_ok { $meta->alias_method()  } '... exception thrown as expected';
    dies_ok { $meta->remove_method() } '... exception thrown as expected';
    
    dies_ok { $meta->add_attribute()    } '... exception thrown as expected';
    dies_ok { $meta->remove_attribute() } '... exception thrown as expected';
                        
    dies_ok { $meta->add_package_variable()    } '... exception thrown as expected';
    dies_ok { $meta->remove_package_variable() } '... exception thrown as expected';

    my @supers;
    lives_ok {
        @supers = $meta->superclasses;
    } '... got the superclasses okay';

    dies_ok { $meta->superclasses([ 'UNIVERSAL' ]) } '... but could not set the superclasses okay';
    
    my $meta_instance;
    lives_ok {
        $meta_instance = $meta->get_meta_instance;
    } '... got the meta instance okay';
    isa_ok($meta_instance, 'Class::MOP::Instance');
    is($meta_instance, $meta->get_meta_instance, '... and we know it is cached');    
    
    my @cpl;
    lives_ok {
        @cpl = $meta->class_precedence_list;
    } '... got the class precedence list okay';    
    is_deeply(
    \@cpl,
    [ 'Bar', 'Foo'],
    '... we just have ourselves in the class precedence list');
    
    my @attributes;
    lives_ok {
        @attributes = $meta->compute_all_applicable_attributes;
    } '... got the attribute list okay';
    is_deeply(
    [ sort { $a->name cmp $b->name } @attributes ],
    [ Foo->meta->get_attribute('bar'), $meta->get_attribute('baz') ],
    '... got the right list of attributes');
}

{
    my $meta = Baz->meta;
    is($meta->name, 'Baz', '... checking the Baz metaclass');    
    
    ok($meta->is_mutable, '... our class is mutable');
    ok(!$meta->is_immutable, '... our class is not immutable');    

    lives_ok {
        $meta->make_immutable();
    } '... changed Baz to be immutable';
    
    ok(!$meta->make_immutable, '... make immutable now returns nothing');
    
    ok(!$meta->is_mutable, '... our class is no longer mutable');
    ok($meta->is_immutable, '... our class is now immutable');    

    isa_ok($meta, 'Class::MOP::Class::Immutable');
    isa_ok($meta, 'Class::MOP::Class');

    dies_ok { $meta->reinitialize() } '... exception thrown as expected';
    
    dies_ok { $meta->add_method()    } '... exception thrown as expected';
    dies_ok { $meta->alias_method()  } '... exception thrown as expected';
    dies_ok { $meta->remove_method() } '... exception thrown as expected';
    
    dies_ok { $meta->add_attribute()    } '... exception thrown as expected';
    dies_ok { $meta->remove_attribute() } '... exception thrown as expected';
                        
    dies_ok { $meta->add_package_variable()    } '... exception thrown as expected';
    dies_ok { $meta->remove_package_variable() } '... exception thrown as expected';

    my @supers;
    lives_ok {
        @supers = $meta->superclasses;
    } '... got the superclasses okay';

    dies_ok { $meta->superclasses([ 'UNIVERSAL' ]) } '... but could not set the superclasses okay';
    
    my $meta_instance;
    lives_ok {
        $meta_instance = $meta->get_meta_instance;
    } '... got the meta instance okay';
    isa_ok($meta_instance, 'Class::MOP::Instance');
    is($meta_instance, $meta->get_meta_instance, '... and we know it is cached');    
    
    my @cpl;
    lives_ok {
        @cpl = $meta->class_precedence_list;
    } '... got the class precedence list okay';    
    is_deeply(
    \@cpl,
    [ 'Baz', 'Bar', 'Foo'],
    '... we just have ourselves in the class precedence list');
    
    my @attributes;
    lives_ok {
        @attributes = $meta->compute_all_applicable_attributes;
    } '... got the attribute list okay';
    is_deeply(
    [ sort { $a->name cmp $b->name } @attributes ],
    [ $meta->get_attribute('bah'), Foo->meta->get_attribute('bar'), Bar->meta->get_attribute('baz') ],
    '... got the right list of attributes');
}


