require 'spec_helper'

describe 'HueConference::Calendar' do
  it "should have a calendar id" do
    calendar = HueConference::Calendar.new('calendar_id')
    calendar.id.should == 'calendar_id'
  end
end

