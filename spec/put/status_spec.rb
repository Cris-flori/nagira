require 'spec_helper'
require_relative 'support'

describe "PUT service status" do

  dont_run_in_production(__FILE__) and break

  include Rack::Test::Methods
  def app
    @app ||= Nagira
  end

  let (:content_type) {  {'Content-Type' => 'application/json'} }

  before :all do
    get "/_status/_list.json"

    @host = JSON.parse(last_response.body).first
    get "/_status/#{@host}/_services.json"

    @input = {
      "service_description" => "Host Service",
      "return_code" => 0,
      "plugin_output" => "Plugin said: Bla"
    }

    @input2 = {
      "service_description" => "Another Host Service",
      "return_code" => 2,
      "plugin_output" => "Plugin said: Bla and Bla"
    }

  end

  before :each do
    File.delete nagios_cmd rescue nil
  end

  let (:host) { @host }

  # ==================================================================
  # Tests
  #

  context "PUT /_status/:host/_services" do

    context :single do

      let (:url) { "/_status/#{host}/_services" }
      before (:each) do
        put url, @input.to_json, content_type
      end

      it_should_behave_like :put_status

      it "URL param hostname is higher priority than JSON" do
        pending
        fail
#         put url, @input.merge({ "host_name" => "fake_host"}).to_json, content_type

#         out = JSON.parse last_response.body
# pp out
#         out["object"]["data"]["host_name"].should eq host
      end

      it "update with valid data" do
        expect(last_response).to be_ok
      end

      it 'Fails with missing data' do
        @input.keys.each do |key|
          data = @input.dup
          data.delete key
          put url, data.to_json, content_type
          expect(last_response.status).to eq 400
        end
      end
    end

    context :multiple do
      let (:url) { "/_status/#{host}/_services" }
      before do
        put url, [@input, @input2].to_json, content_type
      end

      let (:out) { JSON.parse last_response.body }

      it_should_behave_like :put_status

      context "PUT data check" do
        subject {  out["object"] }

        it {  expect(subject).to be_a_kind_of Array }
        it {  expect(subject.size).to eq 2 }
      end
    end
  end

  context "PUT /_status/:host_name/_services/:service_description" do
    let(:url) { "/_status/#{host}/_services/PING" }
    before do
      put url, [{ return_code: 0, plugin_output: "All OK"}].to_json, content_type
    end

    it "writes status" do
      expect(last_response).to be_ok
    end
    it_should_behave_like :put_status

  end



#   context 'host does not exist' do
#     let (:host) { "some_nonexisting_host" }
#     let (:url) { "/_status/#{host}/_services" }

#     it_should_behave_like :put_status
#     it {  pending "Add validaton for host existence in Ruby-Nagios for PUT"}

#     #       it "fails with valid data" do
#     #       end
#     #       it 'fails with invalid data' do
#     #       end

#   end                         # host does not exist


  context "PUT /_status/:host_name/_services/:service_description/_return_code/:return_code/_plugin_output/:plugin_output" do
    it { pending "To be depreciated "; fail}
  end

end                           # update /_hosts
