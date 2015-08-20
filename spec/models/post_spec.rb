require "rails_helper"

describe Post do
  it { should belong_to :user }
  it { should have_and_belong_to_many :tags }
  it { should have_many :comments }

  # TODO
  # it { should have_field(:title) }
  # it { should have_field(:body_markdown) }
  # it { should have_field(:body_html) }

  it { should validate_presence_of :user }
  it { should validate_presence_of :title }

  describe '#notify_twitter' do
    subject { FactoryGirl.build(:post) }

    it 'posts to Twitter after create' do
      expect(subject).to receive(:notify_twitter)
      subject.save!
    end
  end

  describe '#tweet_content' do
    subject { FactoryGirl.build(:post) }

    it 'includes the title in the tweet' do
      subject.id = '123'
      subject.title = 'This is a test discussion'
      expect(subject.tweet_content).to match /^This is a test discussion/
    end

    it 'uses the short domain for links' do
      subject.id = '123'
      expect(subject.tweet_content).to match %r{http://rbga.me/123$}
    end

    it 'keeps the character limit to 140' do
      subject.id = '123'
      subject.title = 'a' * 140
      expect(subject.tweet_content.length).to eq 140
      expect(subject.tweet_content).to eq "#{'a'*121} http://rbga.me/123"

      subject.id = '1234567890'
      expect(subject.tweet_content.length).to eq 140
      expect(subject.tweet_content).to eq "#{'a'*114} http://rbga.me/1234567890"
    end
  end

  describe "#add_vote" do
    before do
      @user = FactoryGirl.create(:user)
      @post = FactoryGirl.create(:post)
    end

    it "creates a vote by the given user" do
      @post.add_vote(@user)
      expect(@post.votes.count).to eq 1
    end

    it "doesn't create a second vote for a given user" do
      @post.add_vote(@user)
      @post.add_vote(@user)

      expect(@post.votes.count).to eq 1
    end
  end

  describe "#has_voted?" do
    before do
      @user = FactoryGirl.create(:user)
      @post = FactoryGirl.create(:post)
    end

    it "returns true if the given user has already voted on the post" do
      expect(@post.has_voted?(@user)).to be_falsey
      @post.add_vote(@user)
      expect(@post.has_voted?(@user)).to be_truthy
    end
  end

  describe "creating tags" do
    before do
      @post = FactoryGirl.create :post
    end

    def post_tag_titles
      @post.tags.map(&:title)
    end

    it "can create all of the tags given from the tags_string accessor" do
      @post.tags_string = "ruby, rails, css"
      @post.save

      expect(post_tag_titles).to match_array ["css", "rails", "ruby"]
    end

    it "normalizes the tags' names" do
      @post.tags_string = " Ruby,  rails,CSS  "
      @post.save

      expect(post_tag_titles).to match_array ["ruby", "rails", "css"]
    end

    it "splits the tags by spaces as well as commas" do
      @post.tags_string = "ruby rails css"
      @post.save

      expect(post_tag_titles).to match_array ["ruby", "rails", "css"]
    end

    it "generates a unique list of tags" do
      @post.tags_string = "ruby, rails, ruby"
      @post.save

      expect(post_tag_titles).to match_array ["ruby", "rails"]
    end

    it "completely replaces the list of tags upon update" do
      @post.tags = [FactoryGirl.create(:tag, title: 'ruby')]
      @post.save!
      @post.reload

      expect(post_tag_titles).to match_array ["ruby"]

      @post.tags_string = "rails, css"
      @post.save

      expect(post_tag_titles).to match_array ["rails", "css"]
    end

    it "checks if a tag title already exists in other posts" do
      @post2 = FactoryGirl.create :post

      @post.tags_string = "ruby, great"
      @post.save

      @post2.tags_string = "rails, great"
      @post2.save

      all_tag_titles = Tag.all.map(&:title)
      expect(all_tag_titles).to match_array ["ruby", "rails", "great"]
    end
  end

  describe "#add_vote" do
    before do
      @user = FactoryGirl.create(:user)
      @post = FactoryGirl.create(:post)
    end

    it "creates a vote by the given user" do
      @post.add_vote(@user)
      expect(@post.votes.count).to eq 1
    end

    it "doesn't create a second vote for a given user" do
      @post.add_vote(@user)
      @post.add_vote(@user)

      expect(@post.votes.count).to eq 1
    end
  end

  describe "#has_voted?" do
    before do
      @user = FactoryGirl.create(:user)
      @post = FactoryGirl.create(:post)
    end

    it "returns true if the given user has already voted on the post" do
      expect(@post.has_voted?(@user)).to be_falsey
      @post.add_vote(@user)
      expect(@post.has_voted?(@user)).to be_truthy
    end
  end
end
