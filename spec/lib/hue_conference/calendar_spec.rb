require 'spec_helper'

describe 'HueConference::Calendar' do
  let(:events_response) { double(items: [ double.as_null_object ]) }
  let(:google_agent) { double(calendar_events: events_response) }
  let(:current_event) { double(started?: true) }
  let(:future_event) { double(started?: false) }
  let(:events) { [current_event, future_event] }
  let(:calendar_id) { 'calendar_id' }
  let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

  it "should have a calendar id" do
    calendar.id.should == calendar_id
  end

  it "should have a google agent" do
    calendar.google_agent.should == google_agent
  end

  describe "sync_events!" do

    before do
      calendar.stub(:build_events)
    end

    it "should sync events from google calendar" do
      google_agent.should_receive(:calendar_events).with(calendar_id)
      calendar.sync_events!
    end

    it "should build the events with the response" do
      calendar.should_receive(:build_events).with(events_response)
      calendar.sync_events!
    end
  end

  describe "#build_events" do
    let(:events_hash) { double(items: ['foo']) }
    let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

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
    let(:unstarted) { double('unstarted', underway?: false, unstarted?: true) }
    let(:underway) { double('underway', underway?: true, unstarted: false) }
    let(:finished) { double('finished', underway?: false, unstarted?: false) }
    let(:events) { [finished, underway, unstarted] }

    let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

    context "when an event is underway" do
      before do
        calendar.instance_variable_set(:@events, events)
      end

      it "should return the event" do
        calendar.current_event.should == underway
      end
    end

    context "when no event is underway" do
      before do
        calendar.instance_variable_set(:@events, [finished, unstarted])
      end

      it "should return the next unstarted event" do
        calendar.current_event.should == unstarted
      end
    end
  end
end

