RSpec.describe User, type: :model do
  describe '#add_points' do
    let!(:user) { FactoryGirl.create(:user, points: 5) }
    it 'points should increase' do
      expect{
        user.add_points(5)
      }.to change(user, :points)
    end
  end

  describe '#subtract_points' do
    let!(:user) { FactoryGirl.create(:user, points: 5) }
    it 'points should decrease' do
      user.subtract_points(1)
      expect(user.points).to eq(5 -1)
    end

    it 'points should equal zero when subtract to larger n.o points' do
      user.subtract_points(15)
      expect(user.points).to eq(0)
    end
  end

  describe '#load_or_search' do
    let!(:user1) {
      user = FactoryGirl.create(:user, first_name: 'Micheal', last_name: 'Jackson')
      user.account.account_emails << FactoryGirl::build(:account_email)
      user
    }
    let!(:user2) {
      user = FactoryGirl.create(:user, last_name: 'Smith')
      user.account.account_emails << FactoryGirl::build(:account_email)
      user
    }

    it 'should return all users with when keyword is empty' do
      results = User.load_or_search(keyword: '')
      expect(results.size).to eq(2)
    end

    it 'should return users match either first name, last name, emails and company_name' do
      # Test match first name
      first_keyword = 'Micheal'
      results = User.load_or_search(keyword: first_keyword)
      expect(results.to_a).to include(user1)

      # Test match last name
      sec_keyword = 'Smith'
      results = User.load_or_search(keyword: sec_keyword)
      expect(results.to_a).to include(user2)

      # Test match company name
      company_keyword = user1.company_name[1..3]
      results = User.load_or_search(keyword: company_keyword)
      expect(results.to_a).to include(user1)
    end

    it 'should return users match email' do
      email = user1.account.account_emails.first.try :email
      if email
        results = User.load_or_search(keyword: email[1..3])
        expect(results.to_a).to include(user1)
      end
    end

    it 'should searching in full name' do
      keyword = 'cheal jac'
      results = User.load_or_search(keyword: keyword)
      expect(results.to_a).to include(user1)
    end

    it 'should non-case sensitive searching' do
      first_keyword = 'mI'
      results = User.load_or_search(keyword: first_keyword)
      expect(results.to_a).to include(user1)

      sec_keyword = 'sMiTH'
      results = User.load_or_search(keyword: sec_keyword)
      expect(results.to_a).to include(user2)
    end
  end
end
