# == Schema Information
# Schema version: 49
#
# Table name: topics
#
#  id           :integer(11)   not null, primary key
#  user_id      :integer(11)   
#  title        :string(255)   
#  created_at   :datetime      
#  views        :integer(11)   default(0)
#  posts_count  :integer(11)   default(0)
#  last_post_id :integer(11)   
#  last_post_at :datetime      
#  last_post_by :integer(11)   
#  private      :boolean(1)    
#  closed       :boolean(1)    
#  sticky       :boolean(1)    
#  forum_id     :integer(11)   
#

class Topic < ActiveRecord::Base
    
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy 
  belongs_to :user
  belongs_to :forum, :counter_cache => true
  belongs_to :last_poster, :foreign_key => "last_post_by", :class_name => "User"
  
  validates_presence_of :user_id, :title, :forum_id
    
  attr_accessor :body
  
  attr_protected :user_id, :created_at, :views, :posts_count, :last_post_id, :last_post_at, :last_post_by
      
  def hit!
    self.class.increment_counter :views, id
  end
  
  def posters
    posts.map { |p| p.user_id }.uniq.size
  end
  
  def updated_at
    last_post_at
  end
    
end
