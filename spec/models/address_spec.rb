RSpec.describe Address, type: :model do
  describe '#bulk_update_opening_hours' do
    let!(:address) { FactoryGirl.create(:address) }

    it 'should save all valid opening hours' do
      bulk_data = [
        {
          day: 1,
          periods: [
            open: {
              hour: 7,
              minute: 0
            },
            close: {
              hour: 11,
              minute: 0
            }
          ]
        },
        {
          day: 2,
          periods: [
            open: {
              hour: 7,
              minute: 0
            },
            close: {
              hour: 11,
              minute: 0
            }
          ]
        }
      ]
      expect{
        address.bulk_update_opening_hours(bulk_data)
      }.to change(OpeningHour, :count).by(2)
    end

    it 'should not save duplicate days in week' do
      bulk_data = [
        {
          day: 1,
          periods: [
            open: {
              hour: 7,
              minute: 0
            },
            close: {
              hour: 11,
              minute: 0
            }
          ]
        },
        {
          day: 1,
          periods: [
            open: {
              hour: 7,
              minute: 0
            },
            close: {
              hour: 11,
              minute: 0
            }
          ]
        }
      ]
      expect{
        address.bulk_update_opening_hours(bulk_data)
      }.to change(OpeningHour, :count).by(1)
    end
  end
end
