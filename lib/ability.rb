class Ability
  include CanCan::Ability
 
  def initialize(user)
    user ||= User.new # guest user
 
    if user.role? :super_admin
      can :manage, :all
    elsif user.role? :forum_admin
      can :manage, [Moderatorship, Monitorship, Topic, Post, User]
    elsif user.role? :registered_user
      can :read, [Moderatorship, Monitorship, Topic, Post]
      # manage products, assets he owns
      can :manage, Topic do |topic|
        topic.try(:owner) == user
      end
      can :manage, Post do |post|
        post.try(:owner) == user
      end
    else 
      can :read, [Moderatorship, Monitorship, Forum, Topic, Post]
    end
  end
end