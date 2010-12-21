class UsersController < ApplicationController
#  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge, :edit]
  before_filter :find_user, :only => [:update, :show, :edit, :suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required
  # /posts
  # /users/1/posts
  # /forums/1/posts
  # /forums/1/topics/1/posts
  def index
    @users = User.all
    @users = @users.paginate(:page => 1, :per_page => 10)
    
    respond_to do |format|
      format.html # index.html.erb
      format.atom # index.atom.builder
      format.xml  { render :xml  => @users }
    end
  end
  def index
    users_scope = admin? ? :all_users : :active_users
    if params[:q]
      @users = User.send(users_scope).named_like(params[:q]).paginate(:page => current_page)
    else
      @users = User.send(users_scope).paginate(:page => current_page)
    end
  end
  
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html 
      format.xml  do
        render :xml  => @user
      end
    end
  end

  def new
  end

  def create
    cookies.delete :auth_token
    @user = current_site.users.build(params[:user])    
    @user.save if @user.valid?
    @user.register! if @user.valid?
    unless @user.new_record?
      redirect_back_or_default('/login')
      flash[:notice] = I18n.t 'txt.activation_required', 
        :default => "Thanks for signing up! Please click the link in your email to activate your account"
    else
      render :action => 'new'
    end
  end

  def edit
    @user = find_user
  end

  def update
    @user = admin? ? find_user : current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User account was successfully updated.'
        format.html { render :action => "edit" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to(forum_topic_path(@forum, @topic)) }
      format.xml  { head :ok }
    end
  end
  
  def make_admin
    redirect_back_or_default('/') and return unless admin?
    @user = find_user
    @user.roles << Role.find_by_name('SuperAdmin')
    @user.save
    redirect_to @user
  end
  
protected
  def find_user
    @user = if admin?
      User.find params[:id]
    elsif params[:id] == current_user.id
      current_user
    else
      User.find params[:id]
    end or raise ActiveRecord::RecordNotFound
  end
  
  def admin?
    user_signed_in? && current_user.is_super_admin?
  end
  
  def find_parents
    if params[:user_id]
      @parent = @user = User.find(params[:user_id])
    elsif params[:forum_id]
      @parent = @forum = Forum.find_by_permalink(params[:forum_id])
      @parent = @topic = @forum.topics.find_by_permalink(params[:topic_id]) if params[:topic_id]
    end
  end

  def find_post
    post = @topic.posts.find(params[:id])
    if post.user == current_user || current_user.is_admin?
      @post = post
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def login_required
    if !user_signed_in?
      redirect_to 'home#index'
    end
  end
  
end