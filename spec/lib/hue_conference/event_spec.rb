require 'spec_helper'

describe "HueConference::Event" do

  let(:starting_date) { DateTime.now - 1 }
  let(:ending_date) { DateTime.now + 2 }
  let(:google_event_object) { double(start: double(dateTime: starting_date, respond_to: nil),
                                     end: double(dateTime: ending_date, respond_to: nil),
                                     summary: "Event Name"
                                    )
  }

  describe "#initialize" do
    let(:starting_time) { Time.parse(starting_date.to_s) }
    let(:ending_time) { Time.parse(ending_date.to_s) }
    let(:starting_callback) {
      OpenStruct.new({
        type: 'starting',
        light: 'outdoor',
        time: starting_time,
        command: { 'on' => true }
      })
    }

    let(:ending_callback) {
      OpenStruct.new({
        type: 'ending',
        light: 'outdoor',
        time: ending_time,
        command: { 'on' => false }
      })
    }
    let(:callbacks) { [starting_callback, ending_callback] }

    let(:event) { HueConference::Event.new(google_event_object) }

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
      event.callbacks.should == callbacks
    end
  end

  describe "#started?" do
    let(:past_time) { Time.now - 1800 }
    let(:future_time) { Time.now + 1800 }

    let(:event) { HueConference::Event.new(google_event_object) }

    context "when an event has started" do
      it "should be true" do
        event.instance_variable_set(:@starting_time, past_time)
        event.started?.should == true
      end
    end

    context "when an event has not started" do
      it "should be false" do
        event.instance_variable_set(:@starting_time, future_time)
        event.started?.should == false
      end
    end
  end

  describe "#finished?" do
    let(:past_time) { Time.now - 1800 }
    let(:future_time) { Time.now + 1800 }

    let(:event) { HueConference::Event.new(google_event_object) }

    context "when an event has ended" do
      it "should be true" do
        event.instance_variable_set(:@ending_time, past_time)
        event.finished?.should == true
      end
    end

    context "when an event has not ended" do
      it "should be false" do
        event.instance_variable_set(:@ending_time, future_time)
        event.finished?.should == false
      end
    end
  end

  describe "#underway?" do
    let(:past_time) { Time.now - 1800 }
    let(:future_time) { Time.now + 1800 }

    let(:event) { HueConference::Event.new(google_event_object) }

    context "when an event has started and is not finished" do
      it "should be true" do
        event.instance_variable_set(:@starting_time, past_time)
        event.instance_variable_set(:@ending_time, future_time)
        event.underway?.should == true
      end
    end

    context "when an event has not started" do
      it "should be true" do
        event.instance_variable_set(:@starting_time, future_time)
        event.instance_variable_set(:@ending_time, future_time)
        event.underway?.should == false
      end
    end

    context "when an event is finished" do
      it "should be true" do
        event.instance_variable_set(:@starting_time, past_time)
        event.instance_variable_set(:@ending_time, past_time)
        event.underway?.should == false
      end
    end
  end

  describe "private methods" do

    let(:event) { HueConference::Event.new(google_event_object) }

    describe "#date_to_utc" do

      it "should convert the date to utc time" do
        date = Date.today
        date_response = double(date: date, dateTime: nil)
        utc_time = Time.parse(date.to_s).utc

        event.send(:date_to_utc, date_response).should == utc_time
      end

      it "should convert the date_time to utc time" do
        date_time = DateTime.now
        date_response = double(dateTime: date_time)
        utc_time = Time.parse(date_time.to_s).utc

        event.send(:date_to_utc, date_response).should == utc_time
      end
    end
  end
end

