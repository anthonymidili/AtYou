class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :avatar, foreign_key: 'avatar_id', class_name: 'Photo'

  has_many :mentions, dependent: :destroy
  has_many :microposts, through: :mentions
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: 'followed_id',
           class_name: 'Relationship', dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :photos, dependent: :destroy
  has_many :comments, foreign_key: 'created_by_user_id', dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }

  scope :find_all_with_names, -> (names) { where(name: names.split(', ')) }
  scope :by_search, -> (search_terms) { order(name: 'ASC').where('name ILIKE ?', "%#{search_terms}%") }

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  def last_post
    microposts.reverse.last.try(:content)
  end

  def is_avatar(photo)
    self.avatar == photos.find_by(id: photo.id)
  end

  def followers_except_mentioned(names)
    followers - User.find_all_with_names(names)
  end
end
