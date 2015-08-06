class Post < ActiveRecord::Base
  has_and_belongs_to_many :tags
  validates :title, presence: true

  scope :internal_post, -> { where(type: "InternalPost") }
  scope :external_post, -> { where(type: "ExternalPost") }

  def types
    %w(ExternalPost InternalPost)
  end
end
