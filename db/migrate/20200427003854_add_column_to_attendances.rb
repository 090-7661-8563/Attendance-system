class AddColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :expected_finish_time,   :datetime   # 残業終了予定時間
    add_column :attendances, :overtime,               :datetime   # 残業時間
    add_column :attendances, :detail,                 :string     # 備考
    add_column :attendances, :reason,                 :string     # 業務処理内容
    add_column :attendances, :modified_started_time,  :datetime   # 編集した勤怠開始時間
    add_column :attendances, :modified_finished_time, :datetime   # 編集した勤怠終了時間
    add_column :attendances, :status_modified,        :integer, default: 0 # 編集承認ステータス
    add_column :attendances, :status_overtime,        :integer, default: 0 # 残業承認ステータス
    add_column :attendances, :status_month,           :integer, default: 0 # ひと月承認ステータス
    add_column :attendances, :superior_id,            :integer # 上長ID  のちにカラム名変更される
    add_column :attendances, :tomorrow,               :boolean, default: false # 翌日フラグ
  end
end
