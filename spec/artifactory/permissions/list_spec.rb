RSpec.describe Artifactory::Permissions do
  let(:api_client) {
    Artifactory::Permissions.api_client endpoint: endpoint,
                                        api_key: "the-secret-api-key"
  }

  let(:endpoint) {
    "http://artifactory.local"
  }

  describe "::list" do
    before do
      stub_request(:get, "#{endpoint}/api/v2/security/permissions")
        .to_return(status: 200,
                   body: payload,
                   headers: { "Content-Type" => "application/json" })
    end

    let(:payload) { File.read "spec/fixtures/list_permission_targets.json" }
    subject { described_class.list api_client: api_client }

    it {
      is_expected.to eq [:ok,
                         [
                          { "name" => "my-permission-target-one",
                            "uri" => "http://my-artifactory.local/api/v2/security/permissions/my-permission-target-one" },
                          { "name" => "my-permission-target-two",
                            "uri" => "http://my-artifactory.local/api/v2/security/permissions/my-permission-target-two" },
                        ]]
    }
  end
end
