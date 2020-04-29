class AddColumnToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_time, :time
    # add_column :users, :specified_working_time, :time
  end
end