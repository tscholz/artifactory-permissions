RSpec.describe Artifactory::Permissions do
  let(:permission_target) {
    Artifactory::Permissions::V2::PermissionTarget.new JSON.load(File.open "spec/fixtures/get_permission_target.json")
  }

  let(:user) { described_class.user name: "me", permissions: %w[read], scope: "repo" }

  let(:invalid_user) { described_class.user name: "", permissions: %w[read], scope: "repo" }

  describe "::delete_user" do
    it "deletes the user" do
      status, pt, errors = described_class.delete_user permission_target: permission_target,
                                                       user: user

      expect(status).to eq :ok
      expect(pt.users.map(&:name)).to eq []
      expect(errors).to be_empty
    end

    it "does not try to delete invalid users" do
      status, pt, errors = described_class.delete_user permission_target: permission_target,
                                                       user: invalid_user

      expect(status).to eq :error
      expect(permission_target.users.map(&:name)).to eq ["me"]
      expect(errors.full_messages).to match /Name can not be empty/
    end
  end
end
