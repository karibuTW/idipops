RSpec.describe OpeningHour, type: :model do
  it 'should not save when periods or day is empty' do
    oh = FactoryGirl.build(:opening_hour, periods: [], day: '')
    expect(oh).to be_invalid
    expect(oh.save).to be false
  end

  it 'should save when valid day and time' do
    oh = FactoryGirl.build(:opening_hour)
    expect(oh).to be_valid
    expect(oh.save).to be true
  end
end
