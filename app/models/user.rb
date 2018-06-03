class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :last_name, presence: true, length: { in: 2..32 }
  validates :first_name, presence: true, length: { in: 2..32 }
  validates :first_name, length: { maximum: 32 }
end
