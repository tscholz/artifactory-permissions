RSpec.describe Artifactory::Permissions do
  let(:permission_target) {
    Artifactory::Permissions::V2::PermissionTarget.new JSON.load(File.open "spec/fixtures/get_permission_target.json")
  }

  let(:group) { described_class.group name: "readers", permissions: %w[read], scope: "repo" }

  let(:invalid_group) { described_class.user name: "", permissions: %w[read], scope: "repo" }

  describe "::delete_group" do
    it "deletes the group" do
      status, pt, errors = described_class.delete_group permission_target: permission_target,
                                                        group: group

      expect(status).to eq :ok
      expect(pt.groups.map(&:name)).to eq []
      expect(errors).to be_empty
    end

    it "does not try to delete invalid groups" do
      status, pt, errors = described_class.delete_group permission_target: permission_target,
                                                        group: invalid_group

      expect(status).to eq :error
      expect(permission_target.groups.map(&:name)).to eq ["readers"]
      expect(errors.full_messages).to match /Name can not be empty/
    end
  end
end
