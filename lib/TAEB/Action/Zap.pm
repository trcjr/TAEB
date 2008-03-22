#!/usr/bin/env perl
package TAEB::Action::Zap;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';
with 'TAEB::Action::Role::Item';

use constant command => 'z';

has '+item' => (
    isa => 'TAEB::Type::Item',
    required => 1,
);

sub respond_zap_what        { shift->item->slot }
sub respond_nothing_happens { shift->item->charges(0) }
sub done                    { shift->item->spend_charge }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

