require_relative '../spec_helper'

def with_config(config_file)
  Gitlab::Devops::Config.apply(YAML.load(IO.read(File.join(File.dirname(__FILE__), config_file))))
end

describe Gitlab::Devops::Config do

  describe 'gitlab config' do
    it 'test that it has a version number' do
      expect(Gitlab::Devops::VERSION).not_to be_nil
    end

    it 'should apply group settings' do
      grps = [Gitlab::ObjectifiedHash.new({id: 1, name: 'group_name'})]
      allow(Gitlab).to receive(:group_search).with('group_name').and_return(grps)

      projects = [Gitlab::ObjectifiedHash.new({id: 1, name: 'global-project-settings'})]
      allow(Gitlab).to receive(:group_projects).with(1).and_return(projects)

      allow(Gitlab).to receive(:project_search).with('valid_name').and_return(projects)

      allow(Gitlab).to receive(:variables).with(1).and_return([])
      allow(Gitlab).to receive(:create_variable).with(1, 'key1', 'value1').and_return(nil)

      expect(with_config('../fixtures/config.yml')).to be_truthy
    end

    it 'should throw error if config has unsupported setting' do
      projects = [Gitlab::ObjectifiedHash.new({name: 'valid_project'})]
      allow(Gitlab).to receive(:project_search).with('valid_name').and_return(projects)
      expect {with_config('../fixtures/config_not_supported_settings.yml')}.to raise_error Gitlab::Error::Error,
                                                                                           "Unsupported setting 'unsupported'. See supported in spec/fixtures/config.yml"
    end

    it 'should throw error if group name not provided' do
      expect {with_config('../fixtures/config_no_grp_name.yml')}.to raise_error Gitlab::Error::Parsing,
                                                                                'Group name must be provided'
    end

    it 'should throw error if group with given name not found' do
      allow(Gitlab).to receive(:group_search).with('wrong_grp_name').and_return([])
      expect {with_config('../fixtures/config_wrong_grp_name.yml')}.to raise_error Gitlab::Error::Error,
                                                                                   'group not found for wrong_grp_name'
    end

    it 'should throw error if project under a group with given name not found' do
      grps = [Gitlab::ObjectifiedHash.new({id: 1, name: 'group_name'})]
      allow(Gitlab).to receive(:group_search).with('group_name').and_return(grps)
      allow(Gitlab).to receive(:group_projects).with(1).and_return([])
      expect {with_config('../fixtures/config_wrong_proj_name1.yml')}.to raise_error Gitlab::Error::Error,
                                                                                     'Project with name wrong_proj_name not found under group group_name'
    end

    it 'should throw_error if a project name not provided' do
      expect {with_config('../fixtures/config_no_proj_name.yml')}.to raise_error Gitlab::Error::Parsing,
                                                                                 'Project name must be provided'
    end

    it 'should throw_error if a project with given name not found' do
      allow(Gitlab).to receive(:project_search).with('wrong_proj_name').and_return([])
      expect {with_config('../fixtures/config_wrong_proj_name.yml')}.to raise_error Gitlab::Error::Error,
                                                                                    'project not found for wrong_proj_name'
    end

  end
end
