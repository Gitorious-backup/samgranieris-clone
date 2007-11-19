class Repository < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :project
  has_many    :permissions
  has_many    :committers, :through => :permissions, :source => :user
  
  validates_presence_of :user_id, :project_id, :name
  validates_format_of :name, :with => /^[a-z0-9_\-]+$/i
  
  before_save :set_as_mainline_if_first
  after_create :add_user_as_committer
  
  BASE_REPOSITORY_URL = "keysersource.org"
  
  def gitdir
    "#{name}.git"
  end
  
  def clone_url
    "git://#{BASE_REPOSITORY_URL}/#{gitdir}"
  end
  
  def push_url
    "git@#{BASE_REPOSITORY_URL}:#{gitdir}"
  end
    
  protected
    def set_as_mainline_if_first
      unless project.repositories.size >= 1
        self.mainline = true
      end
    end
    
    def add_user_as_committer
      committers << user
    end
end