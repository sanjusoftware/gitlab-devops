require_relative '../spec_helper'

def with_config(config_file)
  Gitlab::Devops::Config.apply(YAML.load(IO.read(File.join(File.dirname(__FILE__), config_file))))
end

describe Gitlab::Devops::Config do

  describe 'gitlab config' do
    it 'test that it has a version number' do
      expect(Gitlab::Devops::VERSION).not_to be_nil
    end

    it 'should throw_error if group name not provided' do
      expect{with_config('../fixtures/config_no_grp_name.yml')}.to raise_error Gitlab::Error::Parsing
    end

    it 'should throw_error if group does not exists' do
      gitlab = double("Gitlab")
      allow(gitlab).to receive(:group_search).and_return([])
      expect{with_config('../fixtures/config_no_grp_name.yml')}.to raise_error Gitlab::Error::Error
    end
  end
end
