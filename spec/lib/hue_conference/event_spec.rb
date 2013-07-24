require 'spec_helper'

describe "HueConference::Event" do

  let(:start_time) { DateTime.now }
  let(:end_time) { DateTime.now }
  let(:google_event_object) { double(start: double(dateTime: start_time, date: nil),
                                     end: double(dateTime: end_time, date: nil),
                                     summary: "Event Name"
                                    )
  }
  let(:event) { HueConference::Event.new(google_event_object) }

  before do
    DateTime.stub(:now) { DateTime.new(2010, 1, 1, 10) }
  end

  describe "#initialize" do
    it "should should set the start date" do
      event.start_date.should == DateTime.parse(start_time.to_s)
    end

    it "should should set the end date" do
      event.end_date.should == DateTime.parse(end_time.to_s)
    end

    it "should have an event summary/name" do
      event.name.should == "Event Name"
    end
  end

  describe "#started?" do
    let(:start_time) { DateTime.new(2010, 1, 1, 9) }

    it "should be true if event has started" do
      event.started?.should == true
    end
  end
end

