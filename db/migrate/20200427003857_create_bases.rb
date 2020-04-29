class CreateBases < ActiveRecord::Migration[5.2]
  def change
    create_table :bases do |t|
      t.integer :base_number  #拠点番号
      t.string  :base_name    #拠点名
      t.string  :base_type         #勤怠種類
      
      t.timestamps
    end
  end
end