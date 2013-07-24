require 'spec_helper'

describe 'HueConference::Calendar' do
  let(:current_event) { double(started?: true) }
  let(:future_event) { double(started?: false) }
  let(:events) { [current_event, future_event] }

  it "should have a calendar id" do
    calendar = HueConference::Calendar.new('calendar_id')
    calendar.id.should == 'calendar_id'
  end

  describe "#build_events" do
    let(:events_hash) { double(items: ['foo']) }
    let(:calendar) { HueConference::Calendar.new('calendar_id') }

    before do
      HueConference::Event.stub(:new) { 'foo' }
    end

    it "should build events given Google API Response" do
      HueConference::Event.should_receive(:new).with('foo')
      calendar.build_events(events_hash)
    end

    it "should clear existing events" do
      calendar.instance_variable_set(:@events, ['foo'])
      calendar.build_events(double(items: []))
      calendar.instance_variable_get(:@events).should be_empty
    end
  end

  describe "#current_event" do
    let(:calendar) { HueConference::Calendar.new('calendar_id') }

    it "should return a current event if one is underway" do
      calendar.instance_variable_set(:@events, events)
      calendar.current_event.should == current_event
    end
  end

  describe "#next_event" do
    let(:calendar) { HueConference::Calendar.new('calendar_id') }

    it "should return the next unstarted event" do
      calendar.instance_variable_set(:@events, events)
      calendar.next_event.should == future_event
    end

    it "should return the next event" do
      calendar.instance_variable_set(:@events, events)
      calendar.next_event.should == future_event
    end

    it "should return the first event if no current event" do
      calendar.instance_variable_set(:@events, [future_event])
      calendar.events.should_receive(:first)
      calendar.next_event
    end
  end

end

