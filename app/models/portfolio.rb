class Portfolio < ActiveRecord::Base
    has_many :rules
    has_and_belongs_to_many :stocks
    belongs_to :user
    def to_s
        name
    end
end
