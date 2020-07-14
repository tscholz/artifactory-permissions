RSpec.describe Artifactory::Permissions::V2::Commands::SavePermission do
  let(:command) {
    described_class.new permission_target: permission_target,
                        api_client: api_client
  }

  let(:permission_target) {
    Artifactory::Permissions::V2::PermissionTarget.new({})
  }

  let(:api_client) {
    instance_double Artifactory::Permissions::V2::ApiClient
  }
  describe "#call" do
    it "saves a permission target" do
      expect(api_client).to receive(:save_permission_target)
                              .with(permission_target)
                              .and_return([:ok, nil])

      command.call
    end

    it "adds errors if the permission target can not be saved" do
      expect(api_client).to receive(:save_permission_target)
                              .with(permission_target)
                              .and_return([:error, [{ "status" => "500", "message" => "Internal Server Error" }]])

      command.call

      expect(permission_target.errors.full_messages).to match /500 - Internal Server Error/
    end
  end
end
