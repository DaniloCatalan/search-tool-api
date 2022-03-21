class Language < ApplicationRecord
  belongs_to :developer
  validates :name, presence: true
end
