require 'spec_helper'

describe "HueConference::Event" do

  let(:starting_date) { DateTime.now }
  let(:ending_date) { DateTime.now }
  let(:google_event_object) { double(start: double(dateTime: starting_date, respond_to: nil),
                                     end: double(dateTime: ending_date, respond_to: nil),
                                     summary: "Event Name"
                                    )
  }
  let(:event) { HueConference::Event.new(google_event_object) }

  before do
    DateTime.stub(:now) { DateTime.new(2010, 1, 1, 10) }
  end

  describe "#initialize" do
    let(:starting_time) { Time.parse(starting_date.to_s) }
    let(:ending_time) { Time.parse(ending_date.to_s) }

    let(:starting_callback) {
      {
        type: 'starting',
        light: 'outdoor',
        time: starting_time,
        command: { 'on' => true }
      }
    }

    let(:ending_callback) {
      {
        type: 'ending',
        light: 'outdoor',
        time: ending_time,
        command: { 'on' => false }
      }
    }

    it "should have a formatted event name" do
      event.name.should == "event_name"
    end

    it "should should set the starting time" do
      event.starting_time.should == starting_time
    end

    it "should should set the ending time" do
      event.ending_time.should == ending_time
    end

    it "should set the callbacks for event" do
      event.callbacks.should == [starting_callback, ending_callback]
    end
  end

  describe "#started?" do
    let(:startng_time) { DateTime.new(2010, 1, 1, 9) }

    it "should be true if event has started" do
      event.started?.should == true
    end
  end

  describe "private methods" do

    describe "#convert_date_to_time" do

      it "should convert the date to utc time" do
        date = Date.today
        date_response = double(date: date, dateTime: nil)
        utc_time = Time.parse(date.to_s).utc

        event.send(:convert_date_to_time, date_response).should == utc_time
      end

      it "should convert the date_time to utc time" do
        date_time = DateTime.now
        date_response = double(dateTime: date_time)
        utc_time = Time.parse(date_time.to_s).utc

        event.send(:convert_date_to_time, date_response).should == utc_time
      end
    end
  end
end

