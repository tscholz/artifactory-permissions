RSpec.describe Artifactory::Permissions do
  let(:permission_target) {
    Artifactory::Permissions::V2::PermissionTarget.new JSON.load(File.open "spec/fixtures/get_permission_target.json")
  }

  let(:group) { described_class.group name: "writers", permissions: %w[read write], scope: "repo" }

  let(:invalid_group) { described_class.group name: "", permissions: %w[], scope: "repo" }

  describe "::upsert_group" do
    it "adds the group" do
      status, pt, errors = described_class.upsert_group permission_target: permission_target,
                                                        group: group

      expect(status).to eq :ok
      expect(pt.groups(scope: "repo").map(&:name)).to contain_exactly "readers", "writers"
      expect(errors).to be_empty
    end

    it "does not add invalid users" do
      status, pt, errors = described_class.upsert_group permission_target: permission_target,
                                                        group: invalid_group

      expect(status).to eq :error
      expect(pt.groups.map(&:name)).to contain_exactly "readers"
      expect(errors.full_messages).to match /Name can not be empty./
    end
  end
end
