
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  PROHIBITED_KEYWORDS = ["rerum", "mollitia", "exercitationem", "eum", "omnis", "et", "corporis", "provident", "consequuntur", "qui", "repudiandae", "dolorem", "optio", "recusandae", "assumenda", "pariatur", "nostrum", "unde", "ut", "quia"]
  
  
  validate :content_does_not_contain_prohibited_keywords

  private

  def content_does_not_contain_prohibited_keywords
    # prohibited_keywords = 20.times.map { Faker::Lorem.unique.word }

    PROHIBITED_KEYWORDS.each do |keyword|
      if content.downcase.include?(keyword)
        errors.add(:content, "contains prohibited keyword: #{keyword}")
        break
      end
    end
  end
  
  
end
