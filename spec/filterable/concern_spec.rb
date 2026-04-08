RSpec.describe Filterable::Concern do
  describe ".filter" do
    it "returns all records when filters are nil" do
      Article.create!(:title => "A", :status => "draft")
      Article.create!(:title => "B", :status => "published")

      results = Article.filter(nil)

      expect(results.count).to eq Article.count
    end

    it "returns all records when filters are empty" do
      Article.create!(:title => "A", :status => "draft")
      Article.create!(:title => "B", :status => "published")

      results = Article.filter({})

      expect(results.count).to eq Article.count
    end

    it "filters by a single scope" do
      draft = Article.create!(:title => "Draft", :status => "draft")
      Article.create!(:title => "Published", :status => "published")

      results = Article.filter({ :for_status => "draft" })

      expect(results).to include(draft)
      expect(results.count).to eq 1
    end

    it "combines multiple filters with AND by default" do
      matching = Article.create!(:title => "Match", :status => "published", :author_id => 1)
      Article.create!(:title => "Wrong author", :status => "published", :author_id => 2)
      Article.create!(:title => "Wrong status", :status => "draft", :author_id => 1)

      results = Article.filter({ :for_status => "published", :for_author => 1 })

      expect(results).to contain_exactly(matching)
    end

    it "combines multiple filters with AND when explicitly specified" do
      matching = Article.create!(:title => "Match", :status => "published", :author_id => 1)
      Article.create!(:title => "Wrong author", :status => "published", :author_id => 2)
      Article.create!(:title => "Wrong status", :status => "draft", :author_id => 1)

      results = Article.filter(
        { :for_status => "published", :for_author => 1 },
        :operator => :and
      )

      expect(results).to contain_exactly(matching)
    end

    it "combines multiple filters with OR" do
      by_author = Article.create!(:title => "By author", :status => "draft", :author_id => 1)
      by_status = Article.create!(:title => "Published", :status => "published", :author_id => 2)
      unmatched = Article.create!(:title => "Neither", :status => "draft", :author_id => 2)

      results = Article.filter(
        { :for_status => "published", :for_author => 1 },
        :operator => :or
      )

      expect(results).to include(by_author)
      expect(results).to include(by_status)
      expect(results).not_to include(unmatched)
    end

    it "raises ArgumentError for an unsupported operator" do
      expect {
        Article.filter({ :for_status => "draft" }, :operator => :xor)
      }.to raise_error(ArgumentError, /Unsupported filter operator/)
    end

    it "ignores nil values in the filter hash" do
      Article.create!(:title => "A", :status => "published")
      Article.create!(:title => "B", :status => "draft")

      results = Article.filter({ :for_status => "published", :for_author => nil })

      expect(results.count).to eq 1
    end

    it "works with join-based scopes using AND" do
      tag_ruby = Tag.create!(:name => "ruby")
      tag_rails = Tag.create!(:name => "rails")

      both_tags = Article.create!(:title => "Both")
      both_tags.tags << tag_ruby
      both_tags.tags << tag_rails

      ruby_only = Article.create!(:title => "Ruby only")
      ruby_only.tags << tag_ruby

      rails_only = Article.create!(:title => "Rails only")
      rails_only.tags << tag_rails

      results = Article.filter(
        { :for_tag => [tag_ruby.id], :for_status => "draft" },
        :operator => :and
      )

      expect(results).to be_empty
    end

    it "works with join-based scopes using OR" do
      tag_ruby = Tag.create!(:name => "ruby")
      tag_rails = Tag.create!(:name => "rails")

      ruby_article = Article.create!(:title => "Ruby")
      ruby_article.tags << tag_ruby

      rails_article = Article.create!(:title => "Rails")
      rails_article.tags << tag_rails

      untagged = Article.create!(:title => "Untagged")

      results = Article.filter(
        { :for_tag => [tag_ruby.id], :for_author => rails_article.author_id },
        :operator => :or
      )

      expect(results).to include(ruby_article)
    end

    it "returns distinct records when OR produces duplicates" do
      tag = Tag.create!(:name => "ruby")

      article = Article.create!(:title => "Tagged", :author_id => 1)
      article.tags << tag

      results = Article.filter(
        { :for_tag => [tag.id], :for_author => 1 },
        :operator => :or
      )

      expect(results.to_a.count { |record| record.id == article.id }).to eq 1
    end
  end
end
