class FoodPost < ApplicationRecord
  belongs_to :user
  mount_uploader :image, ImageUploader

  # バリデーション
  validates :title, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  validates :expiration_date, presence: true
  validates :pickup_location, presence: true
  validates :pickup_time_slot, presence: true
  validates :image, presence: true

  # ステータス管理
  enum status: {
    available: 'available',
    reserved: 'reserved',
    completed: 'completed'
  }

  # カスタムバリデーション
  validate :expiration_date_cannot_be_in_past

  # ransack用の検索可能属性
  def self.ransackable_attributes(auth_object = nil)
    %w[title pickup_location expiration_date status]  # statusを追加
  end

  # ransack用の検索可能な関連付け
  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  private

  def expiration_date_cannot_be_in_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "は今日以降の日付を選択してください")
    end
  end
end