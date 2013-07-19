require 'spec_helper'

describe 'HueConference::Calendar' do
  it "should have a calendar id" do
    calendar = HueConference::Calendar.new('calendar_id')
    calendar.id.should == 'calendar_id'
  end

  describe "#build_events" do
    let(:google_events_response) { google_events_response_hash['items'] }
    let(:calendar) { HueConference::Calendar.new('calendar_id') }

    it "should build events given Google API Response" do
      HueConference::Event.should_receive(:new).with(google_events_response[0])
      calendar.build_events(google_events_response)
    end

    it "should clear existing events" do
      calendar.instance_variable_set(:@events, ['foo'])
      calendar.build_events({})
      calendar.instance_variable_get(:@events).should be_empty
    end
  end

  describe "#next_event" do
    let(:calendar) { HueConference::Calendar.new('calendar_id') }

    it "should return soonest starting event" do
      events_stub = double(sort: ["foo", "bar"])
      calendar.instance_variable_set(:@events, events_stub)
      calendar.events.should_receive(:sort)
      calendar.next_event.should == "foo"
    end
  end
end

