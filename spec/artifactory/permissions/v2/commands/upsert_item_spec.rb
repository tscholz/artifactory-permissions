RSpec.describe Artifactory::Permissions::V2::Commands::UpsertItem do
  let(:command) {
    described_class.new permission_target: permission_target,
                        item: item
  }

  let(:permission_target) {
    instance_double(Artifactory::Permissions::V2::PermissionTarget)
  }

  let(:item) {
    Artifactory::Permissions.user name: "Fred", permissions: %w(read), scope: "repo"
  }

  describe "#call" do
    it "validates presence of scope" do
      expect(item).to receive(:scope).and_return ""

      expect { command.call }.to change { item.errors? }
      expect(command.errors.full_messages).to match /Scope can not be empty/
    end

    it "vaidates the scope value" do
      allow(item).to receive(:scope).and_return "invalid-scope"

      expect { command.call }.to change { item.errors? }
      expect(command.errors.full_messages).to match /Unknown scope 'invalid-scope'/
    end

    it "validates presence of name" do
      expect(item).to receive(:name).and_return ""

      expect { command.call }.to change { item.errors? }
      expect(command.errors.full_messages).to match /Name can not be empty/
    end

    it "validates presence of permissions" do
      allow(item).to receive(:permissions).and_return []

      expect { command.call }.to change { item.errors? }
      expect(command.errors.full_messages).to match /Permissions can not be empty/
    end

    it "validates permission entries" do
      allow(item).to receive(:permissions).and_return %w[invalid-permission]

      expect { command.call }.to change { item.errors? }
      expect(command.errors.full_messages).to match /Permissions contain unknown value/
    end

    it "upserts an user to the permission_target" do
      expect(permission_target).to receive(:upsert_user).with(scope: item.scope, name: item.name, permissions: item.permissions)

      command.call
    end

    it "upserts a group to the permission_target" do
      group = Artifactory::Permissions::group name: "Flintstones",
                                              permissions: %w[read],
                                              scope: "repo"

      allow(command).to receive(:item).and_return group

      expect(permission_target).to receive(:upsert_group).with scope: group.scope,
                                                               name: group.name,
                                                               permissions: group.permissions

      command.call
    end
  end
end
