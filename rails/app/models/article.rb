class Article < ApplicationRecord
  self.table_name = 'articles'

  enum :status, { draft: 0, published: 1, archived: 2 }, prefix: :status
  enum :article_type, { guide: 0, tierlist: 1, matchup: 2, news: 3, spotlight: 4, decklist: 5 }, prefix: :article_type

  belongs_to :author, class_name: 'Player'
  belongs_to :featured_deck, class_name: 'Deck', optional: true
  belongs_to :comments, class_name: 'ArticleComment'
  has_many :tags, class_name: 'ArticleTag', through: :article_tag_assignments

  validates :title, presence: true, length: { maximum: 300 }
  validates :slug, presence: true, length: { maximum: 300 }

  def to_s
    title.to_s
  end
end
