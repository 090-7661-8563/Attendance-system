require "time"

class AttendancesController < ApplicationController

# 勤怠編集画面 
  def edit
    @user = User.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
    if current_user.admin? || current_user.id == @user.id

      if not params[:first_day].nil?
        @first_day = Date.parse(params[:first_day])
      else
        @first_day = Date.current.beginning_of_month
      end
      
      @last_day = @first_day.end_of_month
      
      # 取得月の初日から終日まで繰り返し処理
      (@first_day..@last_day).each do |day|
        # attendancesテーブルに各日付のデータがあるか
        if not @user.attendances.any? { |obj| obj.attendance_day == day }
          # ない日付はインスタンスを生成して保存する
          date = Attendance.new(user_id: @user.id, attendance_day: day)
          date.save
        end
      end
      
      # 当月を昇順で取得し@daysへ代入
      @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?', \
      @first_day, @last_day).order('attendance_day')
    else
      flash[:warning] = "他のユーザーの勤怠情報は閲覧できません。"
      redirect_to current_user
    end
  end

# 勤怠編集画面(申請ボタン)

# 上長選択行だけ申請 -> postのsuperior_id がnilでないレコードだけ更新


# 変更後を保存してフラグを立てる　-> 上長モーダルで表示
# ※エラーチェックは編集日付箇所の指示者確認㊞が空欄でないところのみ行うこと
# ・退社時間>出社時間・退社時間もしくは出社時間のみ
# 申請中なら、上長申請中と表示されること
  def update_all
    @user = User.find(params[:id])
    # 日時のフォーマット（:tomorrowの処理も）モデルにないカラムもあるので強制permit!
    attendances_params = Attendance.fmt_modified_params(params).permit!
    
    attendances_params.each do |id, item|
      attendance = Attendance.find(id)

      # 上長選択してる日のみ
      if item["superior_id"].present?

        # 当日以降の編集はadminユーザのみ
        if attendance.attendance_day > Date.current && !current_user.admin?
      
        elsif item["modified_started_time"].blank? && item["modified_finished_time"].blank?

        # 出社時間と退社時間の両方の存在を確認
        elsif item["modified_started_time"].blank? || item["modified_finished_time"].blank?
          flash[:warning] = '出社時間と退社時間を入力してください。'
        
        # 出社時間 > 退社時間ではないか
        elsif item["modified_started_time"].to_s > item["modified_finished_time"].to_s
          flash[:warning] = '出社時間より退社時間が早い項目がありました'
        
        else
          attendance.update_attributes(item)
          flash[:success] = '勤怠編集を申請しました。なお本日以降の申請はできません。'
        end
      end # superior_idの締め
    end # eachの締め
    redirect_to user_url(@user, params:{ id: @user.id, first_day: params[:first_day]})
  end
  
# 残業申請モーダル
  def form_overtime
    # 表示用
    @user = User.find(params[:id])
    # 特定の日付のID
    @day = @user.attendances.where(id: params[:a_id])
    # 自分以外の上長達
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end

#個別残業申請
  def submit_overtime
    @user = User.find(params[:user][:user_id])
    # userに紐づく残業申請日
    @attendance = Attendance.where(id: params[:user][:attendances][:id])
    # フォーマットされたovertime_paramsを更新
    if @attendance.update(Attendance.fmt_overtime_params(overtime_params,params))
      flash[:success] = '残業申請をしました。'
      redirect_to user_url(@user, params:{ id: @user.id, first_day: params[:user][:attendances][:first_day]})
    else
      flash[:danger] = "残業申請に失敗しました。"
      # redirect_to user_url(@user, params:{ id: @user.id, first_day: params[:first_day]})
      render :form_overtime
    end
  end



# 上長ユーザー

# 所属長承認申請確認
  def check_approval
    @user = User.find(params[:id])
    # 残業申請しているusers
    @appli_users = User.join_attendances.merge(Attendance.where_status_approval(1).where_superior_id(@user.id))
    # 重複したuser_idを除外
    @appli_users_uniq = @appli_users.uniq
  end

# 残業申請回答
  def res_approval
    @user =  User.find(params[:id])
    @overtimes = params[:attendances]
    @approval_overtime = Attendance.approval_overtime(attendances_params,@overtimes)
    
    @approval_overtime.each do |id, item|
      attendances = Attendance.find(id)
      
      attendances.update!(item)
    end
  # if で条件分岐　render 
  # 仕様テスト
  # 
  end

# 勤怠変更申請確認
  def check_modified
    @user = User.find(params[:id])
    # 残業申請しているusers
    @appli_users = User.join_attendances.merge(Attendance.where_status_modified(1).where_superior_id(@user.id))
    # 重複したuser_idを除外
    @appli_users_uniq = @appli_users.uniq
  end
  
# 残業申請回答
  def res_modified
    # checked にチェックあるものだけ更新　支持者確認印ステータス　TODO: できてるか確認
    @user =  User.find(params[:id])
    @modifieds = params[:attendances]
    @approval_modified = Attendance.approval_modified(attendances_params,@modifieds)

    
    @approval_modified.each do |id, item|
      attendances = Attendance.find(id)
      
      attendances.update!(item)
    end
  # if で条件分岐　render 
  # 仕様テスト
  # 
  end


# 残業申請確認
  def check_overtime
    @user = User.find(params[:id])
    # 残業申請しているusers
    @appli_users = User.join_attendances.merge(Attendance.where_status_overtime(1).where_superior_id(@user.id))
    # 重複したuser_idを除外
    @appli_users_uniq = @appli_users.uniq
  end

# 残業申請回答
  def res_overtime
    @user =  User.find(params[:id])
    @overtimes = params[:attendances]
    @approval_overtime = Attendance.approval_overtime(attendances_params,@overtimes)
    
    @approval_overtime.each do |id, item|
      attendances = Attendance.find(id)
      
      attendances.update!(item)
    end
  # if で条件分岐　render 
  # 仕様テスト
  # 
  end
  
  # プライベート
  private
  
    def attendances_params
      params.permit(attendances: [ :id, :started_time, :finished_time, :expected_finish_time,
                                  :detail, :reason, :modified_started_time, :modified_finished_time,
                                  :tomorrow, :superior_id, :status_modified, :status_overtime,
                                  :status_month])[:attendances]
    end
    
    # 残業申請用
    def overtime_params
      params.require(:user).permit( attendances: [:id, :overtime,
                                   :expected_finish_time, :reason,
                                   :tomorrow, :superior_id, :status_overtime])[:attendances]
    end
end