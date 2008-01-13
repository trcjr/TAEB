
#!perl -T
use strict;
use warnings;
use Test::More;
use List::Util 'sum';
use TAEB;

my @tests = (
    ["x - 100 gold pieces",
     {identity => "gold piece"}],
    ["a - a +1 long sword (weapon in hand)",
     {identity => "long sword"}],
    ["b - a blessed +0 dagger",
     {identity => "dagger"}],
    ["h - 8 +0 darts",
     {identity => "dart"}],
    ["s - a poisoned +0 arrow",
     {identity => "arrow"}],
    ["p - a +0 boomerang",
     {identity => "boomerang"}],
    ["S - the +0 Cleaver",
     {identity => "Cleaver"}],
    ["c - an uncursed +3 small shield (being worn)",
     {identity => "small shield"}],
    ["o - an uncursed +0 banded mail",
     {identity => "banded mail"}],
    ["q - an uncursed +0 crystal plate mail",
     {identity => "crystal plate mail"}],
    ["h - the uncursed +0 Mitre of Holiness",
     {identity => "Mitre of Holiness"}],
    ["r - a blessed +0 pair of speed boots",
     {identity => "speed boots"}],
    ["t - a set of gray dragon scales",
     {identity => "gray dragon scales"}],
    ["d - 2 uncursed food rations",
     {identity => "food ration"}],
    ["j - a cursed tin of lichen",
     {identity => "tin of lichen"}],
    ["K - an uncursed tin of newt meat",
     {identity => "tin of newt meat"}],
    ["r - an uncursed partly eaten tripe ration",
     {identity => "tripe ration"}],
    ["P - a blessed lichen corpse",
     {identity => "lichen corpse"}],
    ["R - an uncursed guardian naga egg",
     {identity => "guardian naga egg"}],
    ["w - an uncursed empty tin",
     {identity => "empty tin"}],
    ["M - a cursed scroll of light",
     {identity => "scroll of light"}],
    ["N - an uncursed scroll of identify",
     {identity => "scroll of identify"}],
    ["O - a blessed scroll of earth",
     {identity => "scroll of earth"}],
    ["k - an uncursed spellbook of cure sickness",
     {identity => "spellbook of cure sickness"}],
    ["m - an uncursed spellbook of detect unseen",
     {identity => "spellbook of detect unseen"}],
    ["T - the uncursed Book of the Dead",
     {identity => "Book of the Dead"}],
    ["C - an uncursed potion of restore ability",
     {identity => "potion of restore ability"}],
    ["Q - an uncursed diluted potion of speed",
     {identity => "potion of speed"}],
    ["R - a blessed potion of full healing",
     {identity => "potion of full healing"}],
    ["i - an uncursed amulet of ESP",
     {identity => "amulet of ESP"}],
    ["l - a cursed amulet of restful sleep",
     {identity => "amulet of restful sleep"}],
    ["z - an uncursed amulet versus poison",
     {identity => "amulet versus poison"}],
    ["k - the Eye of the Aethiopica",
     {identity => "Eye of the Aethiopica"}],
    ["U - the Amulet of Yendor",
     {identity => "Amulet of Yendor"}],
    ["G - an uncursed ring of conflict",
     {identity => "ring of conflict"}],
    ["S - a cursed -1 ring of protection",
     {identity => "ring of protection"}],
    ["T - a cursed ring of see invisible",
     {identity => "ring of see invisible"}],
    ["B - a wand of fire (0:8)",
     {identity => "wand of fire"}],
    ["U - a wand of speed monster (0:8)",
     {identity => "wand of speed monster"}],
    ["V - a wand of sleep (0:5)",
     {identity => "wand of sleep"}],
    ["e - a +0 pick-axe",
     {identity => "pick-axe"}],
    ["f - a +0 grappling hook",
     {identity => "grappling hook"}],
    ["t - an uncursed large box",
     {identity => "large box"}],
    ["W - a blessed magic lamp (lit)",
     {identity => "magic lamp"}],
    ["m - the Master Key of Thievery",
     {identity => "Master Key of Thievery"}],
    ["G - a cursed partly used wax candle (lit)",
     {identity => "wax candle"}],
    ["u - a figurine of a lichen",
     {identity => "figurine of a lichen"}],
    ["n - an uncursed worthless piece of orange glass",
     {identity => "worthless piece of orange glass"}],
    ["Y - an uncursed dilithium crystal",
     {identity => "dilithium crystal"}],
    ["u - 53 rocks",
     {identity => "rock"}],
    ["n - the Heart of Ahriman",
     {identity => "Heart of Ahriman"}],
    ["v - a statue of a lichen",
     {identity => "statue of a lichen"}],
);
plan tests => sum map { scalar keys %{ $_->[1] } } @tests;

for my $test (@tests) {
    my ($appearance, $expected) = @$test;
    my $item = TAEB::World::Item->new_item($appearance);
    while (my ($attr, $attr_expected) = each %$expected) {
        if (defined $item) {
            is($item->$attr, $attr_expected, "parsed $attr of $appearance");
        }
        else {
            fail("parsed $attr of $appearance");
            diag("$appearance produced an undef item object");
        }
    }
}
