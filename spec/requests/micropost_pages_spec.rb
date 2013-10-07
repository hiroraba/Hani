require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
	expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
	before { click_button "Post" }
	it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
	expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) } 
    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
	expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end

  describe "pagination" do
    before do
      30.times { FactoryGirl.create(:micropost, user: user) } 
      visit root_path
    end
    after { Micropost.delete_all }

    it "should list each micopost" do
      Micropost.paginate(page: 1).each do |micropost|
	expect(page).to have_selector("li", text: micropost.content)
      end
    end
  end

  describe "check delete link" do
    let(:user1) { FactoryGirl.create(:user, email: "hhhh@gmail.com") }
    let(:m1) { FactoryGirl.create(:micropost, user: user1, content: "HELLO") }
    let(:m2) { FactoryGirl.create(:micropost, user: user1, content: "GOODBYE") }

    describe "link found" do
      before do  
        FactoryGirl.create(:micropost, user: user) 
	visit root_path
      end
      it { should have_content("delete") }
    end

    describe "link not found" do
      before do  
	visit user_path(user1.id)
      end
      it { should_not have_content("delete") }
    end
  end
end
