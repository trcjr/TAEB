#!/usr/bin/env perl
package TAEB::AI::Behavior::Identify;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) } TAEB->inventory->inventory;
    return 0 unless @items;

    my $item = shift @items;
    my $pt = $item->possibility_tracker;

    if ($pt->can('engrave_useful') && $pt->engrave_useful) {
        $self->do(engrave => implement => $item);
        $self->currently("Engrave identifying a wand");
        return 100;
    }

    return 0;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    # we only care about unidentified stuff
    return 0 if $item->identity;

    # we only know how to handle wands
    if ($item->appearance eq 'wand') {
        return 1 if $item->possibility_tracker->engrave_useful;
    }

    return 0;
}

1;

