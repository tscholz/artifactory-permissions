RSpec.describe Artifactory::Permissions::Helpers do
  describe "#deep_merge!" do
    it "deep-merges hashes" do
      h = { a: { aa: 1, ab: 2 }, b: 99 }
      o = { a: { ab: 22, ac: 23 } }

      expect { subject.deep_merge! h, o }.to change { h }.to({ a: { aa: 1, ab: 22, ac: 23 }, b: 99 })
    end

    it "adds new keys" do
      h = { a: 1 }

      expect { subject.deep_merge!(h, { a: 1, b: { bb: 1 } }) }.to change { h }.to({ a: 1, b: { bb: 1 } })
    end
  end
end
