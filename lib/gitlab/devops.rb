require_relative '../../lib/gitlab/devops/version'
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
        if group_configs
          group_configs.each do |group_config|
            raise Error::Parsing, 'Group name must be provided' unless group_config['name']
            groups = Gitlab.group_search(group_config['name'])
            raise Error::Error, "group not found for #{group_config['name']}" if groups.empty?
            groups.each do |group|
              apply_group_settings group, group_config
            end
          end
        end

        project_configs = options['projects']
        if project_configs
          project_configs.each do |project_config|
            raise Error::Parsing, 'Project name must be provided' unless project_config['name']
            projects = Gitlab.project_search(project_config['name'])
            raise Error::Error, "project not found for #{project_config['name']}" if projects.empty?
            projects.each do |project|
              apply_project_settings project, project_config['settings']
            end
          end
        end

      end

      def self.apply_group_settings(group, group_config)
        projects = Gitlab.group_projects(group.id)

        project_specific_configs = group_config['projects']

        project_specific_configs.each do |project_config|
          proj_name = project_config['name']
          project = projects.find {|p| p.name == proj_name}
          raise Error::Error, "Project with name #{proj_name} not found under group under #{group_config['name']}" unless project
        end

        projects.each do |project|
          proj_config = project_specific_configs.find {|proj| proj['name'] == project.name}
          project_config = proj_config && proj_config['settings'] ? merge_settings(proj_config['settings'], group_config['settings']) : group_config['settings']

          apply_project_settings(project, project_config)
        end

      end

      def self.merge_settings(proj_settings, grp_settings)
        return unless proj_settings
        grp_settings['variables'] = merge_variables(proj_settings['variables'], grp_settings['variables']) if proj_settings['variables']
        grp_settings
      end

      def self.merge_variables(proj_vars, grp_vars)
        p grp_vars.inspect
        grp_var_names = grp_vars.collect {|hash| hash['key']}

        proj_vars.each do |hash|
          if grp_var_names.include?(hash['key'])
            update_grp_var(grp_vars, hash['key'], hash['value'])
          else
            grp_vars << hash
          end
        end
        grp_vars
      end

      def self.update_grp_var(grp_vars, key_to_replace, new_value)
        grp_vars.inject {|hash| hash['value'] = new_value if hash['key'] == key_to_replace}
      end

      def self.apply_project_settings(project, project_config)
        p "applying settings to project #{project.name}"
        project_config.each do |setting, value|
          case setting
            when 'variables'
              update_project_variables(project, value) if project.name == 'global-project-settings'
            else
              raise Error::Error, "Unsupported setting '#{setting}'. See supported in examples/gitlab.config.yml file"
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
