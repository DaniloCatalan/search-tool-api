class AddDeveloperToLanguages < ActiveRecord::Migration[6.1]
  def change
    add_reference :languages, :developer, null: false, foreign_key: true
  end
end
