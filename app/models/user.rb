class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Finforenet::Models::Authenticable
  include Finforenet::Models::SharedQuery
  include Finforenet::Models::Jsonable
   
  field :email_work,            :type => String
  field :login,                 :type => String
  field :full_name,             :type => String
  field :is_online,             :type => Boolean, :default => false
  field :is_public,             :type => Boolean, :default => false

  index :email_work
  index :login
  index :full_name
  index([[:created_at, Mongo::ASCENDING]])
  index([[:created_at, Mongo::DESCENDING]])
  
  #Association
  has_many :access_tokens,     :dependent => :destroy, :autosave => true
  has_many :feed_accounts,     :dependent => :destroy, :autosave => true, :order => [[ :position, :asc ]]
  has_many :user_company_tabs, :dependent => :destroy, :autosave => true, :order => [[ :position, :asc ]]
  has_many :user_profiles,     :dependent => :destroy, :autosave => true, :class_name => "User::Profile"

  attr_accessor :selected_profiles, :profile_ids
  accepts_nested_attributes_for :access_tokens, :feed_accounts, :user_company_tabs, :user_profiles

  validates_format_of :email_work, 
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
                      :message => "is invalid", 
                      :if => :has_email?

  before_save :before_saving
  
  def self.search_by(opts={})
    search_opts = {:created_at => {"$gte" => 2.weeks.ago.midnight, "$lte" => Time.now.utc}}
    search_opts[:created_at]["$lte"] = opts[:end_at].to_time.utc if opts[:end_at].present?
    search_opts[:created_at]["$gte"] = opts[:start_at].to_time.utc if opts[:start_at].present?
    self.where(search_opts).asc(:created_at)
  end
  
  def self.filter_by(on_page,opts,_includes)
    Kaminari.paginate_array(self.includes(_includes).where(opts).asc(:full_name)).page(on_page).per(25)
  end
  def self.forgot_password(_email, new_password)
    result = self.where({"$or" => [{:email_work => _email}, {:login => _email}]}).first
    if result.present?
      result.update_attribute(:password, new_password)
    else
      result = self.new
      result.errors.add(:email, "or login is not found")
    end
    return result
  end
  
  def selected_profiles
    self.user_profiles.map{|up| up.profile_id}
  end
  
  def create_feed_account(opts)
    if opts[:category].blank?
      self.errors.add(:column, "category is required")
    elsif opts[:title].blank?
      self.errors.add(:column, "title is required")
    else
      self.feed_accounts << FeedAccount.new(opts.merge!({:user_id => self.id}))
      self.save
    end
  end

  def profiles
    Profile.find(self.user_profiles.map(&:profile_ids))
  end
  
  def create_column(account)
	  account = FeedAccount.new(account) if account.class.equal?(Hash)
    self.feed_accounts << account
    self.save
  end
  
  def create_tab(tab)
	  tab = UserCompanyTab.new(tab) if tab.class.equal?(Hash)
    self.user_company_tabs << tab
    self.save
  end
  
  def is_exist(work_email)
    is_exist = User.where(:email_work => work_email).count
    self.errors.add(:email_work, "is already taken.") if is_exist > 0
  end
    
  def create_autopopulate
    ['rss', 'podcast', 'chart'].each do |column|
       options = FeedInfo.send("#{column}_query")
       options = FeedInfo.populated_query(options).merge!(profiles_query(self))   
       
       new_column = FeedAccount.new(options) unless column.match(/chart/i)
       feed_infos = FeedInfo.search_populates(options) 
       feed_infos = FeedInfo.with_populated_prices if column == 'chart' && @feed_infos.size < 1
	    
       feed_infos.each do |feed_info|
	 new_column = FeedAccount.new(options) if column == 'chart'
	 new_column.user_feeds << UserFeed.new({:feed_info_id => feed_info.id, :title => feed_info.title, :category_type => column})
       end
       
       self.feed_accounts << new_column
       UserMailer.missing_suggestions(self.category).deliver if feed_infos.size < 1
     end
     
     self.save
	
     #create populate for company tabs
     options = all_companies_conditions
     profile_ids = @user.profiles.select{|profile| profile.id if !profile.profile_category.title.match(/professi/i) }
     options.merge!({:profile_ids => {"$in" => profile_ids}}) if !profile_ids.size > 0
     tab_infos = FeedInfo.search_populates(@conditions,true)
	
     tab_infos.each do |company_tab|
        self.user_company_tabs << UserCompanyTab.new({:follower => 100, :is_aggregate => false, :feed_info_id => company_tab.id})
     end
     
     self.save
  end
  
  def has_columns?
    (self.feed_accounts.count > 0)
  end

  def self.find_by_id(val)
    self.where(:_id => val).first
  end
  
  def self.by_username(access_uid)
    at = AccessToken.where({:username => access_uid}).first
    at ? at.user : nil
  end
  
  def self.auth_by_security(auth_token, auth_session)
    user = self.where({:single_access_token => auth_token, :perishable_token => auth_session}).first
    user = self.where({:single_access_token => auth_token, :is_public => true}).first if user.blank?
    return user
  end
  
  def self.auth_by_token(params)
    if params[:auth_secret].blank?
      self.auth_by_security(params[:auth_token],params[:auth_session])
    else
      self.auth_by_persistence(params[:auth_token],params[:auth_secret])
    end
  end
  
  def self.auth_by_persistence(auth_token, auth_persistence)
    self.where({:single_access_token => auth_token, :persistence_token => auth_persistence}).first
  end
  
  def self.find_public_profile(pids)
    _users = self.where(:is_public => true)
    _return = {}
    _garbage = []
    _remain = []
    _selecteds = []
    _users.each do |_user|
      _remain = pids - _user.user_profiles.map{|up| up.profile_id.to_s}
      if _remain.size < 1
        #_user.profile_ids = pids
        _user.selected_profiles = pids
        _selecteds = pids
        _return = _user
        break
      elsif _remain.size < _user.user_profiles.count 
        if _garbage.size < 1
          _garbage.push({:user => _user,:remain_size => _remain.size}) 
        else
          last_data = _garbage[0]
          if last_data[:remain_size].to_i > _remain.size
            _garbage.shift
            _garbage.push({:user => _user,:remain_size => _remain.size})
          end  
        end
      end
    end  
    if _return.blank? && _garbage.size > 0
      _return = _garbage.shift[:user]
      _selecteds = pids - _remain
      _return.selected_profiles = _selecteds
      #_return.profile_ids = _selecteds
    end
    return {:user => _return, :selecteds => _selecteds}
  end
  
  def show_column(column_id)
    self.feed_accounts.where(:_id => column_id).first
  end

  def has_email?
    !self.email_work.blank? && self.access_tokens.size < 1
  end

  def not_social_login?
    !(self.access_tokens.count < 1)
  end
  
  def check_profiles(pids)
    if pids.is_a?(Array) && pids.present?
      self.user_profiles.delete_all if self.user_profiles.count > 0
      pids.each do |pid|
        User::Profile.create({:profile_id => pid, :user_id => self.id})
      end
    end
  end

  private
  def before_saving
    check_profiles(self.profile_ids)
  end
end
