class Admin::DashboardController < AdminController

  def index
    @user_count = User.where.not(first_login: nil).count
    @active_user_count = User.with_active_state.count
    # @active_user_count = User.where('last_login >= ?', Date.today - 30).count

    @profession_count = Profession.all.count
    @active_profession_count = Profession.where(active: true).count

    @classified_ad_count = ClassifiedAd.all.count
    @published_classified_ad_count = ClassifiedAd.with_published_state.count

    @post_count = Post.all.count
    @published_post_count = Post.with_published_state.count

    @post_category_count = PostCategory.all.count
    @active_post_count = PostCategory.where(active: true).count
  end

end