RSpec.describe Artifactory::Permissions do
  let(:permission_target) {
    Artifactory::Permissions::V2::PermissionTarget
      .new(JSON.load File.open("spec/fixtures/get_permission_target.json"))
  }

  let(:api_client) {
    Artifactory::Permissions.api_client endpoint: "http://artifactory.local",
                                        api_key: "the-secret-api-key"
  }

  describe "::save" do
    it "saves the permission target" do
      expect(api_client).to receive(:save_permission_target)
                              .with(permission_target)
                              .and_return([:ok, nil])

      status, pt, errors = described_class.save permission_target: permission_target,
                                                api_client: api_client

      expect(status).to eq :ok
      expect(pt).to eq permission_target
      expect(errors).to be_empty
    end

    it "handles errors" do
      expect(api_client).to receive(:save_permission_target)
                              .with(permission_target)
                              .and_return([:error, [{ "status" => 400, "message" => "An Artifactory validation message" }]])

      status, pt, errors = described_class.save permission_target: permission_target,
                                                api_client: api_client

      expect(status).to eq :error
      expect(pt).to eq permission_target
      expect(errors.full_messages).to match /400 - An Artifactory validation message/
    end
  end
end
