RSpec.describe Artifactory::Permissions do
  let(:api_client) {
    Artifactory::Permissions.api_client endpoint: endpoint,
                                        api_key: "the-secret-api-key"
  }

  let(:endpoint) {
    "http://artifactory.local"
  }
  describe "::get" do
    let(:path) { "/api/v2/security/permissions/my-permission-target" }
    let(:payload) { File.read "spec/fixtures/get_permission_target.json" }
    let(:not_found_json) { File.read "spec/fixtures/not_found.json" }

    it "gets permission target by path" do
      stub_request(:get, endpoint + path)
        .to_return(status: 200,
                   body: payload,
                   headers: { "Content-Type" => "application/json" })

      status, pt = described_class.get path, api_client: api_client

      expect(status).to eq :ok
      expect(pt.name).to eq "my-permission-target"
    end

    it "returns error if permission target not found" do
      stub_request(:get, endpoint + path)
        .to_return(status: 404,
                   body: not_found_json,
                   headers: { "Content-Type" => "application/json" })

      status, messages = described_class.get path, api_client: api_client

      expect(status).to eq :error
      expect(messages).to eq [{ "status" => 404, "message" => "Not Found" }]
    end
  end
end
