class AddColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :integer
    add_column :users, :superior, :boolean, default: false
    add_column :users, :designated_start_time, :time
    add_column :users, :designated_finish_time, :time
    add_column :users, :uid, :integer
    
  end
end
