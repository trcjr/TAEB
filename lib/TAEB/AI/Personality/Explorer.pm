#!/usr/bin/env perl
package TAEB::AI::Personality::Explorer;
use TAEB::OO;
extends 'TAEB::AI::Personality::Behavioral';

=head1 NAME

TAEB::AI::Personality::Explore - descend only after exploring the level

=cut

sub weight_behaviors {
    my $fight = TAEB->config->fight_behavior || 'Melee';

    return {
        FixHunger          => 1_000_000,
        Heal               => 750_000,
        FixStatus          => 700_000,
        Defend             => 400_000,
        AttackSpell        => 175_000,
        BuffSelf           => 170_000,
        $fight             => 80_000,
        Projectiles        => 49_000,
        Vault              => 30_000,
        Identify           => 24_750,
        GetItems           => 24_500,
        DipForExcalibur    => 24_000,
        Wish               => 23_000,
        Doors              => 10_000,
        DeadEnd            => 5_000,
        Shop               => 4_000,
        Explore            => 2_500,
        CurseCheck         => 2_250,
        Descend            => 1_000,
        Search             => 300,
        RandomWalk         => 1,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

