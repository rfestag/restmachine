class String
  def slugify
    return self.downcase.gsub(/'/, '').gsub(/[^a-z0-9]+/, '-') do |slug|
      slug.chop! if slug.last == '-'
    end
  end
end
