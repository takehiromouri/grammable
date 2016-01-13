class Post < ActiveRecord::Base
	validates :message, presence: true
	belongs_to :user
end
