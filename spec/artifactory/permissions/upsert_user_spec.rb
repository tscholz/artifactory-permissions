RSpec.describe Artifactory::Permissions do
  let(:permission_target) {
    Artifactory::Permissions::V2::PermissionTarget.new JSON.load(File.open "spec/fixtures/get_permission_target.json")
  }

  let(:user) { described_class.user name: "Fred", permissions: %w[read], scope: "repo" }

  let(:invalid_user) { described_class.user name: "Fred", permissions: %w[], scope: "repo" }

  describe "::upsert_user" do
    it "adds the user" do
      status, pt, errors = described_class.upsert_user permission_target: permission_target,
                                                       user: user

      expect(status).to eq :ok
      expect(pt.users.map(&:name)).to contain_exactly "me", "Fred"
      expect(errors).to be_empty
    end

    it "does not add invalid users" do
      status, pt, errors = described_class.upsert_user permission_target: permission_target,
                                                       user: invalid_user

      expect(status).to eq :error
      expect(pt.users.map(&:name)).to contain_exactly "me"
      expect(errors.full_messages).to match /Permissions can not be empty./
    end
  end
end
