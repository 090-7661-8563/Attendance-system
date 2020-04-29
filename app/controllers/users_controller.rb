require "date"
require "csv"
class UsersController < ApplicationController
  include UsersHelper
  before_action :logged_in_user, only: %i[index edit update destroy]
  before_action :correct_user,   only: %i[show]
  before_action :admin_user,     only: %i[index basic_info destroy 
                                          working_employees_index 
                                          basic_info_edit csv_import]
  before_action :admin_user__current_user,  only: %i[edit update]
  #before_action :superior_user,     only: %i[index basic_info destroy]
  
  
  def index
    @users = User.all.order(id: "ASC").paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def show
    # .find = id のみで探す場合
    @user = User.find(params[:id])
    # 自分以外の上長達
    @superiors = User.where(superior: true).where.not(id: @user.id)
    if current_user.admin? || current_user.id == @user.id ||current_user.superior
      
      # もし今のユーザーが上長なら
      if current_user.superior == true
        
        # 所属長承認ステータスと上長選択が一致するもの
        @appli_approval = Attendance.all.where(superior_id_month: @user.id, status_month: 1)
        if @appli_approval.count > 0
          @approvals = @appli_approval.count.to_s+" 件の通知があります"
        end
        
        # 勤怠変更申請ステータスと上長選択が一致するもの
        @appli_modifed = Attendance.all.where(superior_id_modified: @user.id, status_modified: 1)
        if @appli_modifed.count > 0
          @modifieds = @appli_modifed.count.to_s+" 件の通知があります"
        end
        
        # 残業申請ステータスと上長選択が一致するもの
        @appli_overtimes = Attendance.all.where(superior_id_overtime: @user.id, status_overtime: 1)
        if @appli_overtimes.count > 0
          @overtimes = @appli_overtimes.count.to_s+" 件の通知があります"
        end
        
      end
     
      # 既に表示月があれば、表示月を取得する
      # first_dayがnilでないなら
      if not params[:first_day].nil?
        # Date.parse() 日時を表す文字列を解釈し、数値を返します
        @first_day = Date.parse(params[:first_day])
      else
        # 表示月が無ければ、今月分を表示
        # .beginning_of_month = 今月の初めの日付を取得
        @first_day = Date.current.beginning_of_month
      end
      #最終日を取得する
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
    
    
      # 当月を昇順で取得し@daysへ代入 = @first_day =< >= @last_day
      @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?', \
      @first_day, @last_day).order('attendance_day')
      # 在社時間の集計、ついでに出勤日数も
      i = 0
      @days.each do |d|
        if started_time_for_total(d).present? && finished_time_for_total(d).present?
          second = 0
          second = times(started_time_for_total(d),finished_time_for_total(d))  #times = users_helperで定義している
          @total_time = @total_time.to_i + second.to_i
          i = i + 1
        end
      end
     
      # 出勤日数、どっち使ってもOK
      @attendances_count = i
      @attendances_sum = @days.where.not(started_time: nil, finished_time: nil).count
    else
      flash[:warning] = "他のユーザーの勤怠情報は閲覧できません。"
      redirect_to current_user 
      return
    end
  end
  
  # 出勤ボタン
  def started_time
    @user = User.find(params[:id])
    @started_time = @user.attendances.find_by(attendance_day: Date.current)
    @started_time.update_attributes(started_time: Time.new(Time.now.year,\
    Time.now.month, Time.now.day,Time.now.hour,Time.now.min,0))
    flash[:info] = "本日もよろしくお願いします。"
    redirect_to @user 
  end
  
  # 退勤ボタン
  def finished_time
    @user = User.find(params[:id])
    @finished_time = @user.attendances.find_by(attendance_day: Time.current)
    finishedtime = Time.new(Time.now.year,Time.now.month,\
    Time.now.day,Time.now.hour,Time.now.min,0)
    @finished_time.update_attributes(finished_time: finishedtime)
    flash[:info] = "今日も一日お疲れ様でした。"
    redirect_to @user 
  end

  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "登録が完了しました"
      redirect_back_or @user 
    else
      render 'new'
    end
  end
   
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "個人情報を更新しました"
      if current_user.admin?
        redirect_to users_path and return
      end 
      if @user == current_user
        redirect_to @user and return
      end
    end
    render 'edit'
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました"
    redirect_to users_url
  end
  
  def basic_info
    if params[:id].nil?
       @user  = User.find(current_user.id)
    else
       @user  = User.find(params[:id])
    end
  end
  
  def basic_info_edit
    @user  = User.find(params[:id])
  
    if @user.update_attributes!(user_params)

      flash[:success] = "基本情報を更新しました。"
      redirect_to @user
    else
      flash[:danger] = "基本情報の更新に失敗しました。"
      redirect_to @user
    end
  end
  
  #出勤中社員一覧
  def working_employees_index
    @users = User.all
    @we = []
    @users.each do |user|
      if user.attendances.any?{ |a|
          (a.attendance_day == Date.current &&
          !a.started_time.blank? && a.finished_time.blank? 
          )
        }
        @we.push(user)
      end
    end
    @we = Kaminari.paginate_array(@we).page(params[:page]).per(20)
  end
  
  # CSV入力
  def csv_import
    if params[:csv_file].blank?
      flash[:danger] = "読み込むCSVファイルをセットしてください"
    else
      User.import(params[:csv_file])
      flash[:success] = "ユーザーが追加されました。"
    end
    redirect_to users_path
  end
  
  # CSV出力
  def csv_export
    @user = User.find(params[:id])
    @first_day = Date.parse(params[:first_day])
    @last_day = @first_day.end_of_month
    # 当月を昇順で取得し@daysへ代入
    @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?', \
    @first_day, @last_day).order('attendance_day')
    # flash[:success] = "CSV出力しました"
    # redirect_to @user
  end

  private

  # ストロングパラメーター
    def user_params
      params.require(:user).permit(:name, :email, :department, :password,
                                   :basic_time, :specified_working_time,
                                   :password_confirmation, :employee_number,
                                   :designated_start_time, :designated_finish_time,
                                   :card_id)
    end
    
    def search_params
      params.require(:q).permit(:name_cont)
    end

    # beforeフィルター

    # 正しいユーザーかどうかを確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) || current_user.superior
      if current_user.admin?
        redirect_to(root_url)
      end
    end

    # 管理者かどうかを確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    # 上長かどうかを確認
    def superior_user
      redirect_to(root_url) unless current_user.superior?
    end
    
    def admin_user__current_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user.admin? || current_user?(@user)
    end
end