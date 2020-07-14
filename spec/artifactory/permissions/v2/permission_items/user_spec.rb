RSpec.describe Artifactory::Permissions::V2::PermissionItems::User do
  subject {
    described_class.new name: :fred, permissions: [:read, "write"], scope: :repo
  }

  describe "#name" do
    it { expect(subject.name).to eq "fred" }
  end

  describe "#permissions" do
    it { expect(subject.permissions).to contain_exactly "read", "write" }
  end

  describe "#scope" do
    it { expect(subject.scope).to eq "repo" }
  end

  describe "#errors" do
    it "gives access to the errors object" do
      expect(subject.errors).to be_kind_of Artifactory::Permissions::Errors
    end
  end
end
