# frozen_string_literal: true

module Jazzy
  # Deal with different source code repositories
  module SourceHost
    # Factory to create the right source host
    def self.create(options)
      return unless options.source_host_url || options.source_host_file_url

      case options.source_host
      when :github then GitHub.new
      when :gitlab then GitLab.new
      when :bitbucket then BitBucket.new
      end
    end

    # Use GitHub as the default behaviour.
    class GitHub
      include Config::Mixin

      # Human readable name, appears in UI
      def name
        'GitHub'
      end

      # Jazzy extension with logo
      def extension
        name.downcase
      end

      # Logo image filename within extension
      def image
        'gh.png'
      end

      # URL to link to from logo
      def url
        config.source_host_url
      end

      # URL to link to from a SourceDeclaration
      def item_url(item)
        return unless file_url && item.file

        realpath = item.file.realpath
        return unless realpath.to_s.start_with?(local_root_path)

        path = realpath.relative_path_from(lcoal_root_path)
        "#{file_url}/#{path}##{item_url_fragment(item)}"
      end

      private

      def file_url
        config.source_host_file_url
      end

      def local_root_path
        config.source_directory
      end

      # Source host's line numbering link scheme
      def item_url_fragment(item)
        if item.start_line && (item.start_line != item.end_line)
          "L#{item.start_line}-L#{item.end_line}"
        else
          "L#{item.line}"
        end
      end
    end

    # GitLab very similar to GitHub
    class GitLab < GitHub
      def name
        'GitLab'
      end

      def image
        'gitlab.svg'
      end
    end

    # BitBucket has its own line number system
    class BitBucket < GitHub
      def name
        'Bitbucket'
      end

      def image
        'bitbucket.svg'
      end

      def item_url_fragment(item)
        if item.start_line && (item.start_line != item.end_line)
          "line-#{item.start_line}:#{item.end_line}"
        else
          "line-#{item.line}"
        end
      end
    end
  end
end
