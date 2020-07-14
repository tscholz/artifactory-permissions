RSpec.describe Artifactory::Permissions::V2::PermissionTarget do
  let(:permission_target) {
    described_class.new data
  }

  let(:data) {
    JSON.parse "{\"name\":\"my-permission-target\",\"repo\":{\"repositories\":[\"my-repo-local\"],\"actions\":{\"users\":{\"me\":[\"read\",\"annotate\",\"write\",\"delete\",\"manage\"]},\"groups\":{\"readers\":[\"read\"]}},\"include-patterns\":[\"**\"],\"exclude-patterns\":[]},\"build\":{\"repositories\":[\"my-repo-local\"],\"actions\":{\"users\":{\"me-build\":[\"read\",\"annotate\",\"write\",\"delete\",\"manage\"]},\"groups\":{\"readers-build\":[\"read\"]}},\"include-patterns\":[\"**\"],\"exclude-patterns\":[]}}"
  }

  describe "#name" do
    it "gets the name" do
      expect(permission_target.name).to eq "my-permission-target"
    end
  end

  describe "#users" do
    it "gets the users by scope" do
      expect(
        permission_target.users(scope: :repo).map &:name
      ).to contain_exactly "me"

      expect(
        permission_target.users(scope: :build).map &:name
      ).to contain_exactly "me-build"
    end
    it "gets all users from all scopes" do
      expect(
        permission_target.users.map &:name
      ).to contain_exactly "me", "me-build"
    end
  end

  describe "#groups" do
    it "gets the groups by scope" do
      expect(
        permission_target.groups(scope: :repo).map &:name
      ).to contain_exactly "readers"

      expect(
        permission_target.groups(scope: :build).map &:name
      ).to contain_exactly "readers-build"
    end
    it "gets all groups from all scopes" do
      expect(
        permission_target.groups.map &:name
      ).to contain_exactly "readers", "readers-build"
    end
  end

  describe "#upsert_user" do
    it "adds a user" do
      expect {
        permission_target.upsert_user scope: "repo", name: "Fred", permissions: %w[read]
      }.to change { permission_target.users(scope: "repo").count }.from(1).to 2

      expect(
        permission_target.users.find { |u| u.name == "Fred" }.permissions
      ).to contain_exactly "read"
    end
    it "adds a user even if no users are present in the current data structure" do
      permission_target.payload.dig("repo", "actions").delete("users")
      permission_target.upsert_user scope: "repo", name: "Fred", permissions: %w[read]

      expect(
        permission_target.payload.dig "repo", "actions", "users"
      ).to eq("Fred" => %w(read))
    end

    it "updates existing user" do
      expect {
        permission_target.upsert_user scope: "repo", name: "me", permissions: %w[read]
      }.to change { permission_target.payload.dig("repo", "actions", "users") }
             .from({ "me" => %w[read annotate write delete manage] })
             .to({ "me" => %w[read] })
    end
  end

  describe "#delete_user" do
    it "deletes a user" do
      expect {
        permission_target.delete_user scope: "repo", name: "me"
      }.to change { permission_target.payload.dig "repo", "actions", "users" }
             .to({})
    end
    it "does not fail if the user doesn't exist" do
      expect {
        permission_target.delete_user scope: "repo", name: "i-am-not-there"
      }.not_to change { permission_target.payload }
    end
    it "does not fail if users doesn't exist at all" do
      permission_target.payload.dig("repo", "actions").delete("users")

      expect {
        permission_target.delete_user scope: "repo", name: "i-am-not-there"
      }.not_to change { permission_target.payload }
    end
  end

  describe "#upsert_group" do
    it "adds a group" do
      expect {
        permission_target.upsert_group scope: "repo", name: "writers", permissions: %w[read write]
      }.to change { permission_target.groups(scope: "repo").count }.from(1).to 2

      expect(
        permission_target.groups.find { |u| u.name == "writers" }.permissions
      ).to contain_exactly "read", "write"
    end
    it "adds a group even if no groups are present in the current data structure" do
      permission_target.payload.dig("repo", "actions").delete("groups")
      permission_target.upsert_group scope: "repo", name: "writers", permissions: %w[read write]

      expect(
        permission_target.payload.dig "repo", "actions", "groups"
      ).to eq("writers" => %w[read write])
    end

    it "updates an existing group" do
      expect {
        permission_target.upsert_group scope: "repo", name: "readers", permissions: %w[read annotate]
      }.to change { permission_target.payload.dig("repo", "actions", "groups") }
             .from({ "readers" => %w[read] })
             .to({ "readers" => %w[read annotate] })
    end
  end

  describe "#delete_group" do
    it "deletes a group" do
      expect {
        permission_target.delete_group scope: "repo", name: "readers"
      }.to change { permission_target.payload.dig "repo", "actions", "groups" }
             .to({})
    end

    it "does not fail if the group doesn't exist" do
      expect {
        permission_target.delete_group scope: "repo", name: "not-there"
      }.not_to change { permission_target.payload }
    end

    it "does not fail if groups doesn't exist at all" do
      permission_target.payload.dig("repo", "actions").delete("groups")

      expect {
        permission_target.delete_group scope: "repo", name: "not-there"
      }.not_to change { permission_target.payload }
    end
  end

  describe "#errors" do
    it "gives access to the errors object" do
      expect(permission_target.errors).to be_kind_of Artifactory::Permissions::Errors
    end
  end
end
