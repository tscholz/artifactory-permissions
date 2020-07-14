RSpec.describe Artifactory::Permissions::V2::ApiClient do
  let(:client) { described_class.new endpoint: endpoint, api_key: api_key }

  let(:endpoint) { "http://my-artifactory.local" }

  let(:api_key) { "the-secret-api-key" }

  describe "#list_permissions" do
    let(:payload) {
      File.read "spec/fixtures/list_permission_targets.json"
    }

    it "returns the artifactory list representation" do
      stub_request(:get, "#{endpoint}/api/v2/security/permissions")
        .with(headers: { "X-Jfrog-Art-Api" => "the-secret-api-key" })
        .to_return(status: 200,
                   body: payload,
                   headers: { "Content-Type" => "application/json" })

      expect(client.list_permissions).to eq [:ok, JSON.parse(payload)]
    end

    it "raises on server errors" do
      stub_request(:get, "#{endpoint}/api/v2/security/permissions")
        .to_return(status: [500, "Internal Server Error"])

      expect {
        client.list_permissions
      }.to raise_error Artifactory::Permissions::FatalError, "500 \"Internal Server Error\""
    end

    it "raises on timeouts" do
      stub_request(:get, "#{endpoint}/api/v2/security/permissions")
        .to_timeout

      expect {
        client.list_permissions
      }.to raise_error Artifactory::Permissions::FatalError, "execution expired"
    end

    it "raises on HTTP- and Socket-errors" do
      stub_request(:get, "#{endpoint}/api/v2/security/permissions")
        .to_raise(SocketError.new "Failed to open TCP connection...")

      expect {
        client.list_permissions
      }.to raise_error Artifactory::Permissions::FatalError, /Failed to open TCP connection/
    end
  end

  describe "#find_permission" do
    let(:payload) {
      File.read "spec/fixtures/get_permission_target.json"
    }

    it "finds permission by name" do
      stub_request(:get, "#{endpoint}/api/v2/security/permissions/my-permission-target")
        .with(headers: { "X-Jfrog-Art-Api" => "the-secret-api-key" })
        .to_return(status: 200,
                   body: payload,
                   headers: { "Content-Type" => "application/json" })

      expect(client.find_permission name: "my-permission-target").to eq [:ok, JSON.parse(payload)]
    end

    it "returns :error if permission not found" do
      stub_request(:get, "#{endpoint}/api/v2/security/permissions/my-permission-target")
        .with(headers: { "X-Jfrog-Art-Api" => "the-secret-api-key" })
        .to_return(status: 404,
                   body: File.read("spec/fixtures/not_found.json"),
                   headers: { "content-type" => ["application/json"] })

      expect(client.find_permission name: "my-permission-target").to eq [:error,
                                                                         [{ "status" => 404, "message" => "Not Found" }]]
    end
  end

  describe "#save_permission_target" do
    let(:permission_target) do
      instance_double(Artifactory::Permissions::V2::PermissionTarget, name: "my-permission-target", payload: permission_data)
    end

    # Not needed for this test, just for documentation
    let(:permission_data) {
      { "name" => "my-permission-target", "repo" => { "repositories" => ["my-repo-local"], "actions" => { "users" => { "wilma" => ["read"] }, "groups" => { "readers" => ["read"] } }, "include-patterns" => ["**"], "exclude-patterns" => [] } }
    }

    it "saves a permission target successfully" do
      stub_request(:put, "#{endpoint}/api/v2/security/permissions/my-permission-target")
        .with(headers: { "X-Jfrog-Art-Api" => "the-secret-api-key" })
        .to_return(status: [200, ""])

      expect(client.save_permission_target permission_target).to eq [:ok, nil]
    end

    context "the added user does not exist in Artifactory" do
      before do
        stub_request(:put, "#{endpoint}/api/v2/security/permissions/my-permission-target")
          .with(headers: { "X-Jfrog-Art-Api" => "the-secret-api-key" })
          .to_return(status: 400,
                     body: File.read("spec/fixtures/not_existing_user_error.json"),
                     headers: { "content-type" => ["application/json"] })
      end

      it "returns error messages on foreign validation errors" do
        expect(client.save_permission_target permission_target).to eq [:error, [{ "status" => 400, "message" => "Permission target contains a reference to a non-existing user 'wilma'." }]]
      end
    end

    context "the added permission does not exist in Artifactory" do
      before do
        stub_request(:put, "#{endpoint}/api/v2/security/permissions/my-permission-target")
          .with(headers: { "X-Jfrog-Art-Api" => "the-secret-api-key" })
          .to_return(status: 400,
                     body: File.read("spec/fixtures/invalid_permission_error.json"),
                     headers: { "content-type" => ["application/json"] })
      end

      it "returns error messages on foreign validation errors" do
        expect(client.save_permission_target permission_target).to eq [:error, [{ "status" => 400, "message" => "'HUHU' is not a valid Artifactory permission." }]]
      end
    end

    context "invalid api key" do
      before do
        allow(client).to receive(:api_key).and_return "huhu"

        stub_request(:put, "#{endpoint}/api/v2/security/permissions/my-permission-target")
          .with(headers: { "X-Jfrog-Art-Api" => "huhu" })
          .to_return(status: 403,
                     body: File.read("spec/fixtures/bad_props_error.json"),
                     headers: { "content-type" => ["application/json"] })
      end

      it "returns an error" do
        expect(client.save_permission_target permission_target).to eq [:error, [{ "status" => 403, "message" => "Bad props auth token: apiKey=huhu" }]]
      end
    end

    context "no api-key" do
      before do
        allow(client).to receive(:api_key).and_return ""

        stub_request(:put, "#{endpoint}/api/v2/security/permissions/my-permission-target")
          .with(headers: { "X-Jfrog-Art-Api" => "" })
          .to_return(status: 401,
                     body: File.read("spec/fixtures/unauthorized_error.json"),
                     headers: { "content-type" => ["application/json"] })
      end

      it "returns an error" do
        expect(client.save_permission_target permission_target).to eq [:error, [{ "status" => 401, "message" => "Unauthorized" }]]
      end
    end
  end
end
