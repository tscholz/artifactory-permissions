RSpec.describe Artifactory::Permissions do
  it "has a version number" do
    expect(Artifactory::Permissions::VERSION).not_to be nil
  end

  it { is_expected.to respond_to :upsert_user }

  it { is_expected.to respond_to :upsert_group }

  it { is_expected.to respond_to :delete_user }

  it { is_expected.to respond_to :delete_group }

  describe "::user" do
    subject { described_class.user name: "Fred", permissions: %w[read], scope: "repo" }

    it { is_expected.to be_a Artifactory::Permissions::V2::PermissionItems::User }
  end

  describe "::group" do
    subject { described_class.group name: "readers", permissions: %w[read], scope: "repo" }

    it { is_expected.to be_a Artifactory::Permissions::V2::PermissionItems::Group }
  end

  describe "::api_client" do
    subject {
      Artifactory::Permissions.api_client endpoint: "http://artifactory.local",
                                          api_key: "the-secret-api-key"
    }

    it { is_expected.to be_a Artifactory::Permissions::V2::ApiClient }
  end
end
