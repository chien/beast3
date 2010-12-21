class User < ActiveRecord::Base
#  include AASM
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable#, :confirmable
  has_and_belongs_to_many :roles
  
  formats_attributes :bio
  # For User Status State Machine
=begin
  aasm_column :status  
  aasm_initial_state :passive
  
  aasm_state :passive
  aasm_state :pending, :enter => :do_activation
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete

  aasm_event :register do
    transitions :to => :pending, :from => :passive,  :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end

  aasm_event :activate do
    transitions :to => :active, :from => :pending
  end

  aasm_event :suspend do
    transitions :to => :suspended, :from => [:passive, :pending, :active], :guard => :remove_moderatorships
  end

  aasm_event :delete do
    transitions :to => :deleted, :from => [:passive, :pending, :active, :suspended]
  end

  aasm_event :unsuspend do
    transitions :to => :active, :from => :suspended,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :to => :pending, :from => :suspended,  :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :to => :passive, :from => :suspended
  end
=end
  has_many :moderatorships, :dependent => :delete_all
  has_many :forums, :through => :moderatorships, :source => :forum do
    def moderatable
      find :all, :select => "#{Forum.table_name}.*, #{Moderatorship.table_name}.id as moderatorship_id"
    end
  end

  has_many :posts, :order => "#{Post.table_name}.created_at desc"
  has_many :topics, :order => "#{Topic.table_name}.created_at desc"

  has_many :monitorships, :dependent => :delete_all
  has_many :monitored_topics, :through => :monitorships, :source => :topic, :conditions => {"#{Monitorship.table_name}.active" => true}

  attr_readonly :posts_count, :last_seen_at

  scope :named_like, lambda {|name|
    { :conditions => ["users.display_name like ? or users.first_name like ? or users.last_name like ? or users.email like ?", 
                        "#{name}%", "#{name}%", "#{name}%", "#{name}%"] }}

  scope :active_users, lambda {{ :conditions => ["confirmed_at is not null"] }}

  scope :all_users
                       
  def role?(role)
      return !!self.roles.find_by_name(role.to_s.camelize)
  end
  
  def moderator_of?(forum)
    !!(is_admin? || Moderatorship.exists?(:user_id => id, :forum_id => forum.id))
  end
  
  def is_super_admin?
    role_list = self.roles.collect{|role| role.name}
    role_list.include?("SuperAdmin")
  end
  
  def is_admin?
    role_list = self.roles.collect{|role| role.name}
    role_list.include?("SuperAdmin") || role_list.include?('ForumAdmin')
  end
  
  def active?
    !self.confirmed_at.nil?
  end
  
  def suspended?
    # TODO: implement suspend status
    false
  end

  def available_forums
    @available_forums ||= Forum.all - forums
  end
  
  # Creates new topic and post.
  # Only..
  #  - sets sticky/locked bits if you're a moderator or admin 
  #  - changes forum_id if you're an admin
  #
  def post(forum, attributes)
#    attributes.symbolize_keys!
    Topic.new(attributes) do |topic|
      topic.forum = forum
      topic.user  = self
      revise_topic topic, attributes, moderator_of?(forum)
    end
  end

  def reply(topic, body)
    topic.posts.build(:body => body).tap{ |post|
      post.forum = topic.forum
      post.user  = self
      post.save
    }
  end

  def revise(record, attributes)
    is_moderator = moderator_of?(record.forum)
    return unless record.editable_by?(self, is_moderator)
    case record
      when Topic then revise_topic(record, attributes, is_moderator)
      when Post  then post.save
      else raise "Invalid record to revise: #{record.class.name.inspect}"
    end
    record
  end
  # this is used to keep track of the last time a user has been seen (reading a topic)
  # it is used to know when topics are new or old and which should have the green
  # activity light next to them
  #
  # we cheat by not calling it all the time, but rather only when a user views a topic
  # which means it isn't truly "last seen at" but it does serve it's intended purpose
  #
  # This is now also used to show which users are online... not at accurate as the
  # session based approach, but less code and less overhead.
  def seen!
    now = Time.now.utc
    self.class.update_all ['last_seen_at = ?', now], ['id = ?', id]
    write_attribute :last_seen_at, now
  end
  
  def to_param
    id.to_s # permalink || login
  end

  def self.prefetch_from(records)
    find(:all, :select => 'distinct *', :conditions => ['id in (?)', records.collect(&:user_id).uniq])
  end
  
  def self.index_from(records)
    prefetch_from(records).index_by(&:id)
  end

protected

  def remove_moderatorships
    moderatorships.delete_all
  end
  
  def revise_topic(topic, attributes, is_moderator)
    topic.title = attributes[:title] if attributes.key?(:title)
    topic.sticky, topic.locked = attributes[:sticky], attributes[:locked] if is_moderator
    topic.save
  end
  
end
