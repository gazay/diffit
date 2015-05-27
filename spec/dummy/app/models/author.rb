class Author < ActiveRecord::Base

  diffit

  ## associations

  has_many :posts

end
