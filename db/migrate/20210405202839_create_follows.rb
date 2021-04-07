class CreateFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :follows do |t|
      t.belongs_to :user
      t.belongs_to :following

      t.timestamps
    end
  end
end
