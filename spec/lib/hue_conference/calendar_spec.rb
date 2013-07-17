require 'spec_helper'

describe 'HueConference::Calendar' do
  let(:mock_google_service) { m = mock
                              m.stub(:is_a?) { true }
                              m
  }

  before do
    Google::APIClient::JWTAsserter.stub(:new) { mock_google_service }
  end

  it "should require google calendar service" do
    expect { HueConference::Calendar.new('foo', 'calendar_id') }.to raise_error HueConference::RequireGoogleServiceError
  end

  it "should have a calendar id" do
    calendar = HueConference::Calendar.new(mock_google_service, 'calendar_id')
    calendar.id.should == 'calendar_id'
  end
end
