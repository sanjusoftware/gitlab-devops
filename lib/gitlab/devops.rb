require 'gitlab/devops/version'
require 'yaml'
require 'gitlab'

module Gitlab
  module Devops
    class Config
      def self.apply(options)
        Gitlab.configure do |config|
          config.endpoint = "#{options['api_endpoint']}/#{options['api_version']}"
          config.private_token = options['private_token']
        end

        group_configs = options['groups']
        group_configs.each do |group_config|
          raise Error::Parsing, 'Group name must be provided' unless group_config['name']
          groups = Gitlab.group_search(group_config['name'])
          raise Error::Error, "group not found for #{group_config['name']}" if groups.empty?
          groups.each do |group|
            apply_group_settings group, group_config
          end
        end

      end

      def self.apply_group_settings(group, group_config)
        projects = Gitlab.group_projects(group.id)
        projects.each do |project|
          apply_project_settings(project, group_config['settings'])
        end
      end

      def self.apply_project_settings(project, project_config)
        p "applying settings to project #{project.name}"
        project_config.each do |setting, value|
          case setting
            when 'variables'
              update_project_variables(project, value) if project.name == 'global-project-settings'
            else
              raise "Unsupported setting in config file: #{setting}. Please make sure all setting names mentioned in gitlab.config.yml file are in the defined list"
          end
        end
      end

      def self.update_project_variables(project, variables)
        existing_variables = Gitlab.variables(project.id)
        existing_variables.each do |variable|
          Gitlab.remove_variable(project.id, variable.key)
        end

        variables.each do |variable|
          p "updating var #{variable} for project #{project.name}"
          Gitlab.create_variable(project.id, variable['key'], variable['value'])
        end
      end

    end
  end
end
