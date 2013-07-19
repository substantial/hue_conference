require 'spec_helper'

describe "HueConference::Event" do

  it "should should set the start date" do
    event = HueConference::Event.new(google_events_response_hash['items'][0])
    event.start_date.should == DateTime.parse("2010-07-09T15:00:00-07:00")
  end

  it "should should set the end date" do
    event = HueConference::Event.new(google_events_response_hash['items'][0])
    event.end_date.should == DateTime.parse("2010-07-09T17:00:00-07:00")
  end

  describe "sorting, <==>" do
    let(:old_event) { HueConference::Event.new(google_events_response_hash['items'][0]) }
    let(:new_event) { HueConference::Event.new(google_events_response_hash['items'][0]) }
    let(:newest_event) { HueConference::Event.new(google_events_response_hash['items'][0]) }

    before do
      old_event.instance_variable_set(:@start_date, DateTime.new(2001))
      new_event.instance_variable_set(:@start_date, DateTime.new(2003))
      newest_event.instance_variable_set(:@start_date, DateTime.new(2004))
    end

    it "should know how to compare each other" do
      old_event.should > new_event
      old_event.should > newest_event
    end

    it "should be sortable" do
      [new_event, old_event, newest_event].sort.should == [newest_event, new_event, old_event]
    end
  end

end
