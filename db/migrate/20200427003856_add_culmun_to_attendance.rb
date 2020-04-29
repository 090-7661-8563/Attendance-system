class AddCulmunToAttendance < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :superior_id_month,                      :integer # 上長IDフラグ １ヶ月分
    add_column :attendances, :superior_id_modified,                   :integer # 上長IDフラグ 勤怠変更
    
    rename_column :attendances, :superior_id, :superior_id_overtime  # 上長IDフラグ 残業申請
  end
end
