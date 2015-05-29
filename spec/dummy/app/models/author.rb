class Author < ActiveRecord::Base

  include Diffit::Trackable

  ## associations

  has_many :posts

end
