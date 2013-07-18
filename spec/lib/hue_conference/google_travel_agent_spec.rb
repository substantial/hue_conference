require 'spec_helper'

describe 'HueConference::GoogleTravelAgent' do

  let(:google_config) {
    {
      application_name: 'Foo App',
      key_location: 'config/client.p12',
      google_service_email: 'test@example.com'
    }
  }

  before do
    Google::APIClient.stub(:new) { double.as_null_object }
  end

  it "should require a configuration object" do
    expect { HueConference::GoogleTravelAgent.new('foo') }.to raise_error
  end

  it "should require a complete config" do
    incomplete_config = google_config
    incomplete_config.delete(:key_location)
    expect { HueConference::GoogleTravelAgent.new(incomplete_config) }.to raise_error HueConference::MissingConfigOptions
  end

  it "should create a client with the correct application name" do
    Google::APIClient.should_receive(:new).with(application_name: 'Foo App')
    HueConference::GoogleTravelAgent.new(google_config)
  end

  describe "#calendar_events" do
    let(:raw_calendar_hash) { google_events_response_hash }
    let(:travel_agent) { HueConference::GoogleTravelAgent.new(google_config) }
    let(:mock_service_account) { double(authorize: "authorization") }

    before do
      Google::APIClient.stub(:new) { double(:authorization= => :nil, execute: double(data: raw_calendar_hash))}
      travel_agent.stub(:api_key) { 'api_key' }
      travel_agent.stub(:service_account) { mock_service_account }
      travel_agent.stub(:calendar_service) { c = double
                                             c.stub_chain(:events, :list) { "events_list_api" }
                                             c
      }
    end

    it "should require a calendar id" do
      expect { travel_agent.calendar_events }.to raise_error ArgumentError
    end

    it "should set the client authorization" do
      travel_agent.client.should_receive(:authorization=).with("authorization")
      travel_agent.calendar_events('calendar_id')
    end

    it "should return hash of event info from Google" do
      travel_agent.calendar_events('calendar_id').should == raw_calendar_hash
    end
  end

  describe "private methods" do
    let(:travel_agent) { HueConference::GoogleTravelAgent.new(google_config) }

    describe "scopes" do
      let(:default_scope) { 'https://www.googleapis.com/auth/prediction' }
      let(:calendar_scope) { 'https://www.googleapis.com/auth/calendar.readonly' }
      let(:scopes) { [default_scope, calendar_scope]}

      it "should have a default scope" do
        travel_agent.send(:default_scope).should == default_scope
      end

      it "should have a have a calendar_scope" do
        travel_agent.send(:calendar_scope).should == calendar_scope
      end

      it "should have a have a scopes" do
        travel_agent.send(:scopes).should == scopes
      end
    end

    describe "#api_key" do
      before do
        Google::APIClient::PKCS12.stub(:load_key) { 'some key' }
      end
      it "should load a valid api key" do
        Google::APIClient::PKCS12.should_receive(:load_key).with(google_config[:key_location], 'notasecret')
        travel_agent.send(:api_key).should == 'some key'
      end

      it "should memoize the key" do
        travel_agent.send(:api_key)
        Google::APIClient::PKCS12.should_not_receive(:load_key)
        travel_agent.send(:api_key)
      end
    end

    describe "#service_account" do
      let(:mock_service)  { double }

      before do
        travel_agent.stub(:api_key) { "api_key" }
        travel_agent.stub(:scopes) { "scopes" }
        Google::APIClient::JWTAsserter.stub(:new) { mock_service }
      end

      it "should return a new google service account" do
        Google::APIClient::JWTAsserter.should_receive(:new).with(
          google_config[:google_service_email],
          "scopes",
          "api_key"
        )
        travel_agent.send(:service_account).should == mock_service
      end
    end

    describe "#calendar_service" do

      let(:mock_calendar_service) { double }

      before do
        travel_agent.client.stub(:discovered_api) { mock_calendar_service }
      end

      it "should return a calendar service" do
        travel_agent.send(:calendar_service).should == mock_calendar_service
      end

      it "should discover calendar endpoint" do
        travel_agent.client.should_receive(:discovered_api).with('calendar', 'v3')
        travel_agent.send(:calendar_service)
      end
    end
  end

end

