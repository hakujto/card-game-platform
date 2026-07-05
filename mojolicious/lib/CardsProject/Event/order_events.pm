package CardsProject::Event::Order::OrderPaid;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless {
    order_id => $args{order_id},
    player_id => $args{player_id},
    total => $args{total},
    payment_method => $args{payment_method},
    paid_at => $args{paid_at},
  }, $class;
}

sub order_id { $_[0]->{order_id} }
sub player_id { $_[0]->{player_id} }
sub total { $_[0]->{total} }
sub payment_method { $_[0]->{payment_method} }
sub paid_at { $_[0]->{paid_at} }

package CardsProject::Event::Order::OrderShipped;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless {
    order_id => $args{order_id},
    tracking_number => $args{tracking_number},
    shipped_at => $args{shipped_at},
  }, $class;
}

sub order_id { $_[0]->{order_id} }
sub tracking_number { $_[0]->{tracking_number} }
sub shipped_at { $_[0]->{shipped_at} }

package CardsProject::Event::Order::OrderRefunded;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless {
    order_id => $args{order_id},
    refunded_at => $args{refunded_at},
  }, $class;
}

sub order_id { $_[0]->{order_id} }
sub refunded_at { $_[0]->{refunded_at} }

1;