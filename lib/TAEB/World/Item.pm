#!/usr/bin/env perl
package TAEB::World::Item;
use TAEB::OO 'install_spoilers';
use List::MoreUtils 'uniq';

use overload
    q{""} => sub {
        shift->debug_display;
    };

has raw => (
    isa           => 'Str',
    documentation => "The raw string NetHack gave us for the item. Don't use it for code, use it only for logging.",
);

has appearance => (
    isa           => 'Str',
);

has class => (
    isa           => 'ItemClass',
    default       => 'unknown',
    documentation => "Armor, weapon, scroll, etc.",
);

has slot => (
    isa => 'Str',
);

has quantity => (
    isa     => 'Int',
    default => 1,
);

has buc => (
    isa     => 'BUC',
    default => 'unknown',
);

has is_greased => (
    isa     => 'Bool',
    default => 0,
);

has generic_name => (
    isa           => 'Str',
    default       => '',
    documentation => "called X",
);

has specific_name => (
    isa           => 'Str',
    default       => '',
    documentation => "named X",
);

has is_wielding => (
    isa     => 'Bool',
    default => 0,
);

has is_offhand => (
    isa     => 'Bool',
    default => 0,
);

has is_quivered => (
    isa     => 'Bool',
    default => 0,
);

has price => (
    isa     => 'Int',
    default => 0,
);

has possibility_tracker => (
    is      => 'ro',
    isa     => 'TAEB::Knowledge::Item',
    lazy    => 1,
    default => sub {
        my $self = shift;

        my $possibility_tracker = TAEB->knowledge->appearances->{$self->class};
        if (!$possibility_tracker) {
            TAEB->error($self->raw . " gives no possibility tracker for class " . $self->class);
            return;
        }

        $possibility_tracker = $possibility_tracker->{$self->appearance};
        if (!$possibility_tracker) {
            TAEB->error($self->raw . " gives no possibility tracker for appearance " . $self->appearance);
            return;
        }

        return $possibility_tracker;
    },
    handles => [qw/exclude_possibility has_possibilities possibilities rule_out rule_out_all_but identify_as/],
);

sub new_item {
    my $self = shift;
    my $raw  = shift;

    # XXX: there's no way to tell the difference between an item called
    # "foo named bar" and an item called "foo" and named "bar". similarly for
    # an item called "foo (0:1)". so... don't do that!
    my ($slot, $num, $buc, $greased, $poisoned, $ero1, $ero2, $proof, $used,
        $eaten, $dilute, $spe, $item, $call, $name, $recharges, $charges,
        $ncandles, $lit_candelabrum, $lit, $laid, $chain, $quiver, $offhand,
        $wield, $wear, $price) = $raw =~
        m{^                                                # anchor the regex
          (?:([\w\#\$])\s[+-]\s)?\s*                       # inventory slot
          ([Aa]n?|[Tt]he|\d+)?\s*                          # number
          (blessed|(?:un)?cursed|(?:un)?holy)?\s*          # cursedness
          (greased)?\s*                                    # greasy
          (poisoned)?\s*                                   # poisoned
          ((?:(?:very|thoroughly)\ )?(?:burnt|rusty))?\s*  # erosion 1
          ((?:(?:very|thoroughly)\ )?(?:rotted|corroded))?\s* # erosion 2
          (fixed|(?:fire|rust|corrode)proof)?\s*           # fooproof
          (partly\ used)?\s*                               # candles
          (partly\ eaten)?\s*                              # food
          (diluted)?\s*                                    # potions
          ([+-]\d+)?\s*                                    # enchantment
          (?:(?:pair|set)\ of)?\s*                         # gloves and boots
          (.*?)\s*                                         # item name
          (?:called\ (.*?))?\s*                            # non-specific name
          (?:named\ (.*?))?\s*                             # specific name
          (?:\((\d+):(-?\d+)\))?\s*                        # charges
          (?:\((no|[1-7])\ candles?(,\ lit|\ attached)\))?\s* # lit candelabrum
          (\(lit\))?\s*                                    # lit
          (\(laid\ by\ you\))?\s*                          # eggs
          (\(chained\ to\ you\))?\s*                       # iron balls
          (\(in\ quiver\))?\s*                             # quivered
          (\(alternate\ weapon;\ not\ wielded\))?\s*       # off-hand weapon
          (\(weapon.*?\))?\s*                              # wielding
          (\((?:being|embedded|on).*?\))?\s*               # wearing
          (?:\(unpaid,\ (\d+)\ zorkmids?\))?\s*            # shops
          $                                                # anchor the regex
         }x;

    $item = TAEB::Spoilers::Item->normalize($item);

    $num = 1         if !defined($num) || $num =~ /[at]/i;
    $spe =~ s/^\+//  if defined $spe;
    $ncandles = 0    if (defined $ncandles && $ncandles =~ /no/);
    $lit = 1         if (defined $lit_candelabrum && $lit_candelabrum =~ /lit/);

    if ($num < 1) {
        TAEB->warning("Parsed the quantity of '$raw' as $num!");
    }

    my $new_item;
    unless (defined $item) {
        TAEB->error("Couldn't find the base item type for '$raw'!");
        return;
    }

    my $class = TAEB::Spoilers::Item->type_to_class($item);
    unless (defined $class) {
        TAEB->error("Unable to find '$item' in TAEB::Spoilers::Item.");
        return;
    }

    my $class_name = ucfirst $class;
    unless (grep { $class_name eq $_ } TAEB::Spoilers::Item->types) {
        TAEB->error("Items (such as $raw) of class $class are not yet supported.");
        return;
    }

    $new_item = "TAEB::World::Item::$class_name"->new(raw => $raw);

    # XXX: once the EliteBot item identification code gets merged
    # in here, this might have to be changed, but it's good enough
    # for now
    my $stats = "TAEB::Spoilers::Item::$class_name"->$class($item);

    if (defined TAEB->knowledge->appearance_of->{$item}) {
        $new_item->appearance(TAEB->knowledge->appearance_of->{$item});
    }
    elsif (defined($stats) && defined($stats->{appearance})) {
        $new_item->appearance($stats->{appearance});
    }
    else {
        if (!exists TAEB::Spoilers::Item->list->{$item}) {
            TAEB->warning("Can't find $item as either an identity or an appearance");
        }
        $new_item->appearance($item);
    }

    if (defined $buc) {
        $buc =~ s/unholy/cursed/;
        $buc =~ s/holy/blessed/;

        $new_item->buc($buc);
    }

    # XXX: this should go into Spoilers::Item::Tool at some point
    my $is_weaptool = $class eq 'tool' && $item =~ /pick-axe|hook|unicorn/;
    if (!defined $buc &&
        ($class eq 'weapon' || $class eq 'wand' || $is_weaptool)) {
        $new_item->buc('uncursed') if defined $spe || defined $charges;
    }

    $new_item->slot($slot)                 if defined $slot;
    $new_item->quantity($num)              if defined $num;
    $new_item->is_greased(1)               if defined $greased;
    $new_item->is_poisoned(1)              if defined $poisoned;
    if (defined $ero1) {
        $new_item->erosion1(1);
        $new_item->erosion1(2)             if $ero1 =~ /very/;
        $new_item->erosion1(3)             if $ero1 =~ /thoroughly/;
    }
    if (defined $ero2) {
        $new_item->erosion2(1);
        $new_item->erosion2(2)             if $ero2 =~ /very/;
        $new_item->erosion2(3)             if $ero2 =~ /thoroughly/;
    }
    $new_item->is_fooproof(1)              if defined $proof;
    $new_item->is_partly_used(1)           if defined $used;
    $new_item->is_partly_eaten(1)          if defined $eaten;
    $new_item->is_diluted(1)               if defined $dilute;
    $new_item->enchantment($spe)           if defined $spe;
    $new_item->recharges($recharges)       if defined $recharges;
    $new_item->charges($charges)           if defined $charges;
    $new_item->candles_attached($ncandles) if defined $ncandles;
    $new_item->generic_name($call)         if defined $call;
    $new_item->specific_name($name)        if defined $name;
    $new_item->is_lit(1)                   if defined $lit;
    $new_item->is_quivered(1)              if defined $quiver;
    $new_item->is_offhand(1)               if defined $offhand;
    $new_item->is_laid_by_you(1)           if defined $laid;
    $new_item->is_chained_to_you(1)        if defined $chain;
    $new_item->is_wielding(1)              if defined $wield;
    $new_item->is_wearing(1)               if defined $wear;
    $new_item->price($price)               if defined $price;

    return $new_item;
}

sub identity {
    my $self = shift;

    my @possibilities = $self->possibilities;
    return undef if @possibilities != 1;
    return $possibilities[0];
}

sub debug_display {
    my $self = shift;
    my $quan = $self->quantity == 1 ? '' : $self->quantity . 'x ';
    my $enchantment = $self->can('ench') && $self->enchantment
                    ? $self->ench . ' '
                    : '';

    my $name = $self->identity || $self->appearance;
    return sprintf '[%s: %s%s%s]',
                    blessed($self),
                    $quan,
                    $enchantment,
                    $name;
}

sub lookup_spoiler {
    my $self  = shift;
    my $field = shift;
    my @values;

    if (my $stats = TAEB::Spoilers::Item->stats($self->appearance)) {
        push @values, grep { defined }
                      $stats->{$field};
    }
    else {
        for ($self->possibilities) {
            push @values, grep { defined }
                          TAEB::Spoilers::Item->stats($_, $field);
        }
    }

    if (wantarray) {
        return uniq @values;
    }
    else {
        my %seen;
        $seen{$_}++
            for @values;

        my $max = $values[0];
        for (keys %seen) {
            $max = $_ if $seen{$_} > $seen{$max};
        }

        return $max;
    }
}

sub is_autopickuped {
    my $self = shift;
    return 1 if $self->appearance eq 'gold piece';
    return 1 if $self->class eq 'wand';

    return 0;
}

my @check = qw/appearance quantity/;
sub maybe_is {
    my $self  = shift;
    my $other = shift;

    for (@check) {
        if ($self->$_ ne $other->$_) {
            return 0;
        }
    }

    return 1;
}

sub throw_range {
    my $self = shift;
    my $range = int(TAEB->senses->numeric_strength / 2);

    if ($self->identity eq 'heavy iron ball') {
        $range -= int($self->weight / 100);
    }
    else {
        $range -= int($self->weight / 40);
    }

    $range = 1 if $range < 1;

    if ($self->identity =~ /\b(?:arrow|crossbow bolt)\b/
        || $self->class eq 'gem') {
        if (0 && "Wielding a bow for arrows or crossbow for bolts or sling for gems") {
            ++$range;
        }
        elsif ($self->class ne 'gem') {
            $range = int($range / 2);
        }
    }

    # are we on Air? are we levitating?

    if ($self->identity eq 'boulder') {
        $range = 20;
    }
    elsif ($self->identity eq "Mjollnir") {
        $range = int(($range + 1) / 2);
    }

    # are we underwater?

    return $range;
}

install_spoilers(qw/weight base edible artifact material sdam ldam/);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

