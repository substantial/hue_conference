require 'spec_helper'

describe "HueConference::Event" do
  let(:start_time) { Time.now }
  let(:end_time) { Time.now }
  let(:google_event_object) { double(start: double(dateTime: start_time),
                                     end: double(dateTime: end_time),
                                     summary: "Event Name"
                                    )
  }

  it "should should set the start date" do
    event = HueConference::Event.new(google_event_object)
    event.start_date.should == DateTime.parse(start_time.to_s)
  end

  it "should should set the end date" do
    event = HueConference::Event.new(google_event_object)
    event.end_date.should == DateTime.parse(end_time.to_s)
  end

  it "should have an event summary/name" do
    event = HueConference::Event.new(google_event_object)
    event.name.should == "Event Name"
  end

  describe "sorting, <==>" do
    let(:old_event) { HueConference::Event.new(google_event_object) }
    let(:new_event) { HueConference::Event.new(google_event_object) }
    let(:newest_event) { HueConference::Event.new(google_event_object) }

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

