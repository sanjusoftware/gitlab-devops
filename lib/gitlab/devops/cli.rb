require_relative '../../gitlab/devops'

module Gitlab
  module Devops
    class Cli
      def self.run(args)
        unless args.size == 1
          puts 'Syntax: gitlab-devops your-gitlab-config.yml'
          exit(-1)
        end
        gitlab_config_file = args[0]
        p "file is #{gitlab_config_file}"
        Gitlab::Devops::Config.apply(YAML.load(IO.read(gitlab_config_file)))
      end
    end
  end
end
