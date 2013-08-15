require 'spec_helper'

describe 'HueConference::Calendar' do

  let(:calendar_id) { 'calendar_id' }
  let(:google_agent) { double }

  describe "#initialize" do
    let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

    it "should require a calendar_id" do
      expect{ HueConference::Calendar.new }.to raise_error ArgumentError
    end

    it "should require a calendar_id and google_agent" do
      expect{ HueConference::Calendar.new(calendar_id) }.to raise_error ArgumentError
    end

    it "should assign an id instance variable" do
      calendar.instance_variable_get(:@id).should == calendar_id
    end

    it "should assign a google agent instance variable" do
      calendar.instance_variable_get(:@google_agent).should == google_agent
    end

    it "should assign an events collection" do
      calendar.instance_variable_get(:@events).should == []
    end
  end

  describe "sync_events!" do
    let(:events_response) { double(items: [double]) }
    let(:google_agent) { double(calendar_events: events_response) }
    let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

    before do
      calendar.stub(:build_events)
    end

    it "should sync events from google calendar" do
      google_agent.should_receive(:calendar_events).with(calendar_id)
      calendar.sync_events!
    end

    describe "when there are events" do
      it "should build the events with the response" do
        calendar.should_receive(:build_events).with(events_response)
        calendar.sync_events!
      end
    end

    describe "when there no events" do
      before do
        google_agent.stub_chain(:calendar_events, :items) { [] }
      end

      it "should not build any events" do
        calendar.should_not receive(:build_events).with(events_response)
        calendar.sync_events!
      end
    end
  end

  describe "#build_events" do

    let(:events_response) { double(items: ['foo']) }
    let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

    before do
      HueConference::Event.stub(:new)
    end

    it "should build events given Google API Response" do
      HueConference::Event.should_receive(:new).with('foo')
      calendar.build_events(events_response)
    end

    it "should clear existing events" do
      calendar.instance_variable_set(:@events, ['foo'])
      calendar.build_events(double(items: []))
      calendar.instance_variable_get(:@events).should be_empty
    end
  end

  describe "#current_events" do
    let(:event_one) { double }
    let(:event_two) { double }
    let(:event_three) { double }
    let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

    context "when there is one event" do
      it "should only return that event" do
        calendar.instance_variable_set(:@events, [event_one])
        calendar.current_events.should == [event_one]
      end
    end

    context "when there are more than two events" do
      it "should only return the first two events" do
        calendar.instance_variable_set(:@events, [event_one, event_two, event_three])
        calendar.current_events.should == [event_one, event_two]
      end
    end
  end

  describe "#event_callbacks" do
    let(:callback) { double }
    let(:event) { double(callbacks: [callback]) }
    let(:calendar) { HueConference::Calendar.new(calendar_id, google_agent) }

    it "should return a collection of current event callbacks" do
      calendar.instance_variable_set(:@events, [event])
      calendar.event_callbacks.should == [callback]
    end
  end
end

