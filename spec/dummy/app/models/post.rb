class Post < ActiveRecord::Base

  include Diffit::Trackable

  scope :authored_by, ->(author) { where(author_id: author.id) }

  ## associations

  belongs_to :author

end
