class FoodPostsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_food_post, only: [:show, :edit, :update, :destroy]
  

  # 利用可能な食品投稿を取得
  # includes(:user)でN+1問題を回避
  # 賞味期限が近い順にソート
  # ページネーション対応
  def index
    @q = FoodPost.ransack(params[:q])
    @food_posts = @q.result(distinct: true)
                    .available
                    .includes(:user)
                    .order(expiration_date: :asc)
                    .paginate(page: params[:page], per_page: 10)
  end

  def show
    # before_actionで@food_postが設定済み
  end

  def new
    # 現在のユーザーに紐づく新規投稿フォームを作成
    @food_post = current_user.food_posts.new
  end

  def create
    @food_post = current_user.food_posts.new(food_post_params)
    
    if @food_post.save
      redirect_to @food_post, notice: '食品を投稿しました'
    else
      # バリデーションエラー時は入力フォームを再表示
      render :new
    end
  end

  def edit
    # 投稿者以外は編集不可
    unless @food_post.user == current_user
      redirect_to food_posts_path, alert: '編集権限がありません'
    end
  end

  def update
    # 投稿者本人であり、かつ更新が成功した場合
    if @food_post.user == current_user && @food_post.update(food_post_params)
      flash[:success] = '投稿を更新しました'
      redirect_to @food_post
    else
      render :edit
    end
  end

  def destroy
    if @food_post.user == current_user
      @food_post.destroy
      flash[:success] = '投稿を削除しました'
      redirect_to food_posts_path
    else
      flash[:danger] = '削除権限がありません'
      redirect_to food_posts_path
    end
  end

  private

  def set_food_post
    @food_post = FoodPost.find_by(id: params[:id])
    if @food_post.nil?
      flash[:alert] = "投稿が見つかりません"
      redirect_to food_posts_path
    end
  end

  def food_post_params
    params.require(:food_post).permit(
    :title,
    :description,
    :quantity,
    :unit,
    :expiration_date,
    :pickup_location,
    :pickup_time_slot,
    :image
   )
  end



end
