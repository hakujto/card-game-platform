package CardsProject::Event::TradeTransaction::TransactionCompleted;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless {
    transaction_id => $args{transaction_id},
    buyer_id => $args{buyer_id},
    seller_id => $args{seller_id},
    final_price => $args{final_price},
    completed_at => $args{completed_at},
  }, $class;
}

sub transaction_id { $_[0]->{transaction_id} }
sub buyer_id { $_[0]->{buyer_id} }
sub seller_id { $_[0]->{seller_id} }
sub final_price { $_[0]->{final_price} }
sub completed_at { $_[0]->{completed_at} }

1;