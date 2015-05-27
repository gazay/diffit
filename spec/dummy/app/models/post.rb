class Post < ActiveRecord::Base

  diffit

  scope :authored_by, ->(author) { where(author_id: author.id) }

  ## associations

  belongs_to :author

end
